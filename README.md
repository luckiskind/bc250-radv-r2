> **Choose a profile:** [Performance R4 (experimental)](profiles/performance/README.md) preserves the faster normal-routing Control configuration. [R2 recovery](https://github.com/luckiskind/bc250-radv-r2/releases/tag/r2-20260921) remains unchanged for Borderlands 4 and games needing containment. Selection is per game, not automatic hybrid detection; the performance launcher refuses Borderlands. Both retain documented experimental limitations.

# BC250 RADV R2 — experimental per-game driver

**Baseline credit: [lonewolf0622’s BC-250 Mesh Shader Patch — driconf Edition](https://github.com/lonewolf0622/BC-250-Mesh-Shader-Patch---driconf-Edition-opt-in-per-application-).** That project provided the baseline BC250 mesh-support groundwork for this work. Thanks also to the Mesa/RADV/ACO, vkd3d-proton, DXIL-SPIRV, Wine and Proton developers. This is a separate experimental continuation, not an official Mesa/Valve release or an endorsement by those authors.

R2 enables an experimental native mesh-rendering path on **physical GFX1013 / AMD BC-250**, with hybrid compute-emulated TASK support and a patched vkd3d queue-routing workaround. Install it alongside your ordinary driver and enable it only for selected games.

**This is the preserved R2 recovery configuration.** Compact-vertex mapping is disabled because it reproduced board hangs. The later compute-once materialization experiment (reported at 18 FPS), aggressive FP16, native TASK, and compute CU-mode experiments are **not included in the launch policy**. The later zeroed-private-GTT experiment is also excluded; this release preserves R2 rather than silently adding an incompletely qualified memory change.

## Requirements

- Linux x86_64, BC250/GFX1013, native Steam installation. Flatpak Steam and 32-bit games are not qualified.
- A working BC250 kernel/firmware/display setup. Tested on CachyOS `7.2.4-1.136-cachyos-bore-bc250` with the GFX1013 async-compute kernel work. The installer does **not** flash firmware or install a kernel. See [DryhoppedIPA/bc250-gfx1013-fix](https://github.com/DryhoppedIPA/bc250-gfx1013-fix) for the separate kernel project; this package is not that patch.
- **Proton 11.0-2c**, version string `proton-11.0-2c-x86_64`, already installed. Other Proton bases are intentionally rejected by this binary installer.
- Python 3.11+, Bash, GNU coreutils (`cp`, `readlink`), and the native Vulkan loader. The driver needs glibc 2.38 or newer and the shared libraries listed in [BUILD.md](BUILD.md). The installer checks unresolved dependencies instead of replacing system libraries.
- MangoHud for the FPS/frametime overlay. If absent, the launcher continues without the overlay. `BC250_FPS_OVERLAY=0` disables it.
- Disk space for a private Proton copy. Reflinks are used where available; otherwise this can take several GiB.

## Install

Download `bc250-r2-linux-x86_64.tar.gz` and `SHA256SUMS` from the [R2 release](https://github.com/luckiskind/bc250-radv-r2/releases/tag/r2-20260921). Checksums detect corruption; they are not a separate signing trust chain.

```bash
sha256sum --ignore-missing -c SHA256SUMS
tar -xzf bc250-r2-linux-x86_64.tar.gz
cd bc250-r2-linux-x86_64
bash install.sh --proton-base "$HOME/.local/share/Steam/steamapps/common/Proton 11.0"
```

Use your actual Proton directory if it differs. The installer checks its version before proceeding. For another native Steam location, also pass `--steam-root "/path/to/Steam"`.

The installer verifies the exact tested payloads, creates a **private copy** of Proton, installs the patched 64-bit `d3d12core.dll` into that copy, and registers **BC250 R2 (experimental)** as a Steam compatibility tool. It does not overwrite the original Proton, the system Mesa driver, game files, or game settings. Existing installation destinations are refused rather than overwritten. No sudo is needed.

Restart Steam. For the chosen game:

1. Properties → Compatibility → select **BC250 R2 (experimental)**.
2. Properties → General → Launch Options:

```text
"/home/YOUR_USERNAME/.local/bin/bc250-r2" %command%
```

The installer prints the exact command for your username. Both steps matter: a Mesa-only launch with ordinary Proton does not activate this patched queue workaround. The launcher refuses an unexpected Proton command rather than silently running the wrong combination.

Verify installed files without launching a game:

```bash
~/.local/bin/bc250-r2 --check
```

For a native 64-bit Vulkan program, use `bc250-r2 --native program arguments...`; the D3D12 queue workaround does not apply to native Vulkan applications.

## What it does — and does not do

- Mesh-only draws use native direct mesh dispatch where eligible, avoiding the earlier synthetic TASK scheduling overhead. Oversized primitive output is split into bounded child draws.
- Actual application TASK shaders use the existing **compute-emulated producer / native mesh consumer** path in this release. This is not native hardware TASK support.
- The vkd3d patch routes ordinary D3D12 COMPUTE queues to the graphics family. COPY and internal compute remain distinct. This is containment of the observed queue-sensitive failure, not a proven repair of its initiating defect and not an ACE-wide or compute-stage-wide disable.
- R2 adds keyed preparation caching, bounded command-buffer-owned transient suballocation, parallel cull compaction where eligible, and guarding of eligible output arithmetic by its owning slice. It does **not** execute every mesh body only once.
- Balanced child capacity and proven single-piece bypass remain enabled. Compact vertices stay **off**.
- Private nonzeroed/unprotected allocations can use GTT to reduce carveout contention. Zero-initialized and shared allocations retain R2 behavior; framebuffer allocation failures can still occur.
- The patched vkd3d opt-in permits mesh exposure without the usual barycentrics requirement. It does not implement missing barycentrics, force a game to choose mesh rendering, or spoof a universal DirectX 12 Ultimate feature set. No `VKD3D_FEATURE_LEVEL=12_2` override is applied.

## Known limitations

This is experimental, not Vulkan/D3D conformance certification. Board hangs, GPU context loss, visual errors, compilation delays and memory pressure remain possible. Keep your ordinary driver/Proton configuration available. No performance uplift is guaranteed; some games' non-mesh fallback is faster.

The compact-vertex policy reproduced Borderlands context loss and remains disabled. Normal async queue routing still has unresolved failures. R2 itself has produced framebuffer pin `-12` errors with RAM available; those errors are not proof of a system-wide OOM or a complete explanation of earlier hangs. SMU metrics-read errors were observed in one surviving menu run. Broad application compatibility, 32-bit support, arbitrary shader outputs, and sustained stability are not established.

Steam may override the requested Mesa cache directory with its per-game shader cache. Policy differences remain part of the driver cache identity; do not call game comparisons strictly cold-cache merely because this launcher requested another directory.

See [VALIDATION.md](VALIDATION.md) for what was tested and what remains unverified, [CHANGELOG.md](CHANGELOG.md) for the development history, and [BUILD.md](BUILD.md) for source/build instructions.

## Roll back or uninstall

Remove the launch option and choose your ordinary Proton in Steam. That restores normal per-game driver selection without uninstalling anything.

From the extracted bundle, with the same install arguments if customized:

```bash
python3 install.py --uninstall
```

Only directories carrying this installer's ownership marker are removed. Shader caches, original Proton, system drivers and game prefixes remain. Close games using this tool before uninstalling.

## Source and licenses

Release assets include the exact Mesa source snapshot, vkd3d source plus its modified compiler dependencies, checksums, and cumulative patches. The binary is the preserved tested artifact, not an untested rebuilt substitute. See `manifest.json`, `dependency-provenance.json` and [THIRD-PARTY.md](THIRD-PARTY.md). The source snapshots are also available to modify/rebuild under their component licenses.

## Report a problem

Include game name, distro/kernel, selected Proton, `bc250-r2 --check` result, resolution/settings, whether the ordinary fallback works, and the relevant redacted kernel/game error. Distinguish a game exit, black screen, stalled window and full board hang. Do not post Steam tokens, credentials, private game command lines or unredacted unrelated system logs.
