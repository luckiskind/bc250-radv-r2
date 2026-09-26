# Source and build provenance

The packaged Mesa library is the preserved R4 artifact, SHA256 `67fc476a4cd56aedbf0e59f16d1c71b9cacf2dce9643410ea587e03f0e4be474`. The development build output was verified byte-identical before packaging. No new compiler build replaces the playtested binary.

`mesa-performance-source.tar.gz` snapshots tracked working-tree source at HEAD `38a3f9bb3a7119af8ab7e9ab82555e0127d5f1ce` plus the dirty source changes recorded in `mesa-performance.patch`. The patch is cumulative against R2 Mesa `424ccf62d2247ad9aff09195e95dac6ff6c4db9f`; `source-manifest.json` hashes files and records provenance. It is not a clean upstream commit series. The final ACO snapshot was compared to the saved candidate after-files. Build outputs are not claimed bit-for-bit reproducible across machines/toolchains.

Mesa source includes dormant diagnostics and rejected selectable experiments. Read the launcher policy; their presence does not mean they run. Do not enable profiling or remove synchronization as an assumed performance improvement.

Use the same build dependencies as the R2 [build guide](https://github.com/luckiskind/bc250-radv-r2/blob/main/BUILD.md):

```bash
mkdir mesa-performance-source
tar -xzf mesa-performance-source.tar.gz -C mesa-performance-source
meson setup mesa-performance-build mesa-performance-source \
  --buildtype=debugoptimized -Dvulkan-drivers=amd -Dgallium-drivers= \
  -Dllvm=disabled -Dglx=disabled -Degl=disabled \
  -Dgles1=disabled -Dgles2=disabled -Dbuild-tests=true
ninja -C mesa-performance-build
```

Meson may fetch declared source dependencies; inspect wraps or supply distro dependencies for offline builds. Library dependencies must resolve locally. Never replace system libraries with arbitrary downloaded binaries to satisfy this package.

The patched64-bit vkd3d DLL is unchanged from R2, SHA256 `1dd2de3737fa70b2131368304c36d8fae0797fb7f3bfe1357b207c59739686c5`, source commit `3dc6c269a9eaa66aca6b5e6ff958326a3bcffcb0`. Exact corresponding source and modified dependency sources are in [R2's vkd3d source asset](https://github.com/luckiskind/bc250-radv-r2/releases/download/r2-20260921/vkd3d-r2-source.tar.gz); provenance and licenses are included here. No semaphore diagnostic DLL is substituted.

Installers copy an already-installed Proton11.0-2c privately. They do not distribute Proton or the custom kernel. Preserve all upstream license notices when modifying or redistributing source.
