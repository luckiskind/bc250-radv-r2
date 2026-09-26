#!/usr/bin/env python3
"""Install the versioned BC250 Performance bundle without replacing system drivers."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

VERSION = 'performance-r4-20260926'
MARKER = '.bc250-performance-managed'

def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()

def inside(path, root):
    return path.resolve().is_relative_to(root.resolve())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--proton-base', type=Path, help='Installed, tested Proton 11.0-2c directory')
    parser.add_argument('--steam-root', type=Path, default=Path.home()/'.local/share/Steam')
    parser.add_argument('--prefix', type=Path, default=Path.home()/'.local/share/bc250-performance'/VERSION)
    parser.add_argument('--bin-dir', type=Path, default=Path.home()/'.local/bin')
    parser.add_argument('--verify-only', action='store_true')
    parser.add_argument('--uninstall', action='store_true')
    args = parser.parse_args()
    prefix = args.prefix.expanduser().absolute()
    tool = args.steam_root.expanduser().resolve()/'compatibilitytools.d'/'BC250-Performance'
    command = args.bin_dir.expanduser().absolute()/'bc250-performance'
    if args.uninstall:
        for path in (tool, prefix):
            marker = path/MARKER
            if path.is_symlink() or not marker.is_file() or marker.read_text().strip() != VERSION:
                raise SystemExit(f'Refusing to remove unrecognized installation: {path}')
        if command.is_symlink() and command.resolve() == (prefix/'run.sh').resolve():
            command.unlink()
        shutil.rmtree(tool)
        shutil.rmtree(prefix)
        print('Removed BC250 Performance private installation. System drivers, original Proton and caches retained.')
        return
    bundle = Path(__file__).resolve().parent
    manifest = json.loads((bundle/'manifest.json').read_text())
    for name, expected in manifest['payload_sha256'].items():
        path = bundle/name
        if not inside(path, bundle) or not path.is_file() or digest(path) != expected:
            raise SystemExit(f'Missing or altered release payload: {name}')
    print('Release payload checksums verified.')
    if args.verify_only:
        return
    if os.uname().machine != 'x86_64':
        raise SystemExit('This binary bundle is for Linux x86_64 only.')
    if not args.proton_base:
        parser.error('--proton-base is required; the installer does not download or replace Proton')
    base = args.proton_base.expanduser().resolve()
    if not (base/'proton').is_file() or not (base/'toolmanifest.vdf').is_file():
        raise SystemExit('Not a Proton distribution directory.')
    if 'proton-11.0-2c-x86_64' not in (base/'version').read_text():
        raise SystemExit('Use the tested Proton 11.0-2c base. Other bases are not qualified for this bundle.')
    dll_relative = Path('files/lib/wine/vkd3d-proton/x86_64-windows/d3d12core.dll')
    if not (base/dll_relative).is_file():
        raise SystemExit('Expected 64-bit vkd3d-proton layout not found in base Proton.')
    if prefix.exists() or tool.exists() or command.exists() or command.is_symlink():
        raise SystemExit('An install destination already exists. Use --uninstall on a managed install first; no files replaced.')
    check = subprocess.run(['ldd', str(bundle/'payload/libvulkan_radeon.so')], capture_output=True, text=True)
    if check.returncode or 'not found' in check.stdout:
        raise SystemExit('Driver dependencies unavailable:\n'+check.stdout+check.stderr)
    prefix.parent.mkdir(parents=True, exist_ok=True)
    tool.parent.mkdir(parents=True, exist_ok=True)
    command.parent.mkdir(parents=True, exist_ok=True)
    driver_stage = Path(tempfile.mkdtemp(prefix='.bc250-stage-', dir=prefix.parent))
    proton_stage = Path(tempfile.mkdtemp(prefix='.bc250-stage-', dir=tool.parent))
    installed = []
    try:
        shutil.copy2(bundle/'payload/libvulkan_radeon.so', driver_stage/'libvulkan_radeon.so')
        for name in ('run.sh', 'manifest.json', 'README.md', 'LICENSE', 'THIRD-PARTY.md'):
            shutil.copy2(bundle/name, driver_stage/name)
        shutil.copytree(bundle/'licenses', driver_stage/'licenses')
        (driver_stage/'run.sh').chmod(0o755)
        (driver_stage/'icd.json').write_text(json.dumps({'file_format_version':'1.0.0', 'ICD':{'library_path':str(prefix/'libvulkan_radeon.so'), 'api_version':'1.3.0'}}, indent=2))
        (driver_stage/'config.json').write_text(json.dumps({'proton':str(tool/'proton')}, indent=2))
        # Reflinks save disk where supported; no hardlinks to the user's original Proton.
        subprocess.run(['cp', '-a', '--reflink=auto', str(base)+'/.', str(proton_stage)], check=True)
        target = proton_stage/dll_relative
        if not inside(target, proton_stage) or target.is_symlink():
            raise RuntimeError('Proton DLL path escapes its private copy; refusing to modify it.')
        shutil.copy2(bundle/'payload/d3d12core.dll', target)
        if digest(target) != manifest['payload_sha256']['payload/d3d12core.dll']:
            raise RuntimeError('Copied DLL failed verification.')
        (proton_stage/'compatibilitytool.vdf').write_text('"compatibilitytools" { "compat_tools" { "BC250-Performance" { "install_path" "." "display_name" "BC250 Performance (experimental)" "from_oslist" "windows" "to_oslist" "linux" } } }\n')
        for directory in (driver_stage, proton_stage):
            (directory/MARKER).write_text(VERSION+'\n')
        driver_stage.rename(prefix); installed.append(prefix)
        proton_stage.rename(tool); installed.append(tool)
        command.symlink_to(prefix/'run.sh')
    except BaseException:
        for path in installed:
            shutil.rmtree(path)
        raise
    finally:
        for path in (driver_stage, proton_stage):
            if path.exists():
                shutil.rmtree(path)
    print('Installed. Restart Steam; select "BC250 Performance (experimental)" in the game compatibility settings.')
    print(f'Steam launch options: "{command}" %command%')
    print('The system driver and original Proton are unchanged. Remove the launch option and select ordinary Proton to roll back.')

if __name__ == '__main__':
    main()
