# Credits and licensing

## BC250 baseline

**lonewolf0622** — [BC-250 Mesh Shader Patch — driconf Edition (opt-in per application)](https://github.com/lonewolf0622/BC-250-Mesh-Shader-Patch---driconf-Edition-opt-in-per-application-).

Prominent baseline credit is intentional. This repository packages a later experimental continuation; it does not claim authorship of lonewolf's groundwork, imply endorsement, or attribute our later failures/experiments to lonewolf. The original project's scripts are not bundled as if written here.

## Components

- **Mesa / RADV / ACO and contributors**: Mesa source is predominantly MIT-style with other per-file licenses. The source archive preserves notices; `licenses/mesa-license.rst` provides the upstream overview. Follow the actual source notices, not the wrapper license, for driver code.
- **vkd3d-proton / Wine contributors**: LGPL-2.1-or-later and individual notices as specified in the source. `licenses/vkd3d-LGPL-2.1.txt` and `licenses/vkd3d-COPYING.txt` accompany the binary. Complete corresponding source, including modified compiler dependencies, is a release asset.
- **DXIL-SPIRV / DXBC-SPIRV, SPIRV-Tools, SPIRV-Cross, Khronos headers**: retain their own licenses/notices in the corresponding-source archive; dependency revisions and modifications are listed in `dependency-provenance.json`.
- **Valve Proton / Wine / DXVK and other Proton components**: not redistributed as a full runtime here. The installer makes a local copy of the user's installed Proton and preserves its notices.
- **DryhoppedIPA / BC250 kernel-patch contributors**: [bc250-gfx1013-fix](https://github.com/DryhoppedIPA/bc250-gfx1013-fix) is a separate kernel project relevant to the test environment. This release neither installs it nor claims its work as its own.

The top-level `LICENSE` applies only to newly authored packaging scripts and documentation. It does not relicense Mesa, vkd3d, compiler dependencies or others' work.
