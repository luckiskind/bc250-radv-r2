# Source and build

The release distributes corresponding source archives as assets, not just links to mutable worktrees:

- `mesa-r2-source.tar.gz`: tracked source at `424ccf62d2247ad9aff09195e95dac6ff6c4db9f`, based on Mesa `da14d65e4499e66468094be52bff9ea0915a695e` (26.2.1).
- `vkd3d-r2-source.tar.gz`: source at `3dc6c269a9eaa66aca6b5e6ff958326a3bcffcb0`, including copied source for all compiler/header submodules and the two downstream missing-header fixes. See `dependency-provenance.json` for exact revisions.
- `mesa-r2.patch` and `vkd3d-r2.patch`: cumulative main-tree differences against the base commits in `manifest.json`. The vkd3d patch alone does not include dependency changes; use the complete source archive or apply those dependency edits separately.

Source snapshots preserve upstream licenses and notices. Build outputs depend on toolchain and system libraries; these instructions are not a claim of bit-for-bit reproducible binaries. The packaged binary is the preserved tested artifact with its original checksum and debug information.

## Mesa

Install your distribution's Mesa build dependencies, Python build modules, Meson, Ninja, a C/C++ compiler and development headers. Package names vary. The installer deliberately does not execute distro package-manager or kernel commands.

```bash
mkdir mesa-r2-source
tar -xzf mesa-r2-source.tar.gz -C mesa-r2-source
meson setup mesa-r2-build mesa-r2-source \
  --buildtype=debugoptimized \
  -Dvulkan-drivers=amd -Dgallium-drivers= \
  -Dllvm=disabled -Dglx=disabled -Degl=disabled \
  -Dgles1=disabled -Dgles2=disabled -Dbuild-tests=true
ninja -C mesa-r2-build
```

Meson may fetch declared source-only fallback dependencies (for example Wayland protocols); inspect the source wrap files or supply your distribution's development packages for an offline build. Upstream source URL: https://gitlab.freedesktop.org/mesa/mesa.

The packaged native driver dynamically links libdrm/amdgpu, libelf, X11/XCB libraries, Wayland client, zlib, zstd, libxshmfence, libdisplay-info.so.3, libudev, expat, libSPIRV-Tools.so, libstdc++, libgcc, libc and libm (plus their dependencies). Its GLIBC symbol floor is 2.38. Run `ldd payload/libvulkan_radeon.so`; do not substitute random downloaded system libraries if a dependency is missing. Build from source for your distro instead.

## vkd3d-proton

Install Meson, Ninja and the x86_64 MinGW toolchain, including the resource/IDL tools needed by the upstream project. The archive includes its `build-win64.txt` cross file.

```bash
mkdir vkd3d-r2-source
tar -xzf vkd3d-r2-source.tar.gz -C vkd3d-r2-source
meson setup vkd3d-r2-build vkd3d-r2-source \
  --cross-file vkd3d-r2-source/build-win64.txt \
  --buildtype=release -Denable_tests=true -Denable_extras=false
ninja -C vkd3d-r2-build
```

The relevant output is `libs/d3d12core/d3d12core.dll`. Upstream: https://github.com/HansKristian-Work/vkd3d-proton. The downstream patch adds opt-in mesh-without-barycentrics exposure and selective queue routing; it leaves internal compute routing separate.

To use a modified build, create your own bundle and update its manifest hashes deliberately. The installer/launcher rejects a silently substituted binary. You may replace/rebuild LGPL components under their license; the checksums are integrity checks, not a technical prohibition on modification.

## Kernel and Proton

The release does not distribute the full Proton or custom kernel. The installer copies an existing tested Proton base into a separate compatibility-tool directory and replaces only its 64-bit vkd3d core. All other components and their notices remain those of that base. Kernel/firmware compatibility remains the user's prerequisite; native TASK and unrestricted async game routing are not advertised as repaired.
