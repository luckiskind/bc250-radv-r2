# BC250 Performance R4 — experimental per-game profile

This is a separate opt-in performance profile. **Keep the unchanged [R2 recovery release](https://github.com/luckiskind/bc250-radv-r2/releases/tag/r2-20260921) for Borderlands 4 and games requiring the conservative configuration.** Neither profile is universally stable. Selection is per game, not automatic TASK/hybrid-pipeline detection.

Baseline credit: [lonewolf0622's BC-250 Mesh Shader Patch](https://github.com/lonewolf0622/BC-250-Mesh-Shader-Patch---driconf-Edition-opt-in-per-application-). Thanks to Mesa/RADV/ACO/NIR, vkd3d-proton, DXIL-SPIRV, Wine and Proton contributors. This is an experimental continuation, not an official release from those projects.

## What changed

Preserved R4 driver with normal compute queue routing, direct export reads from original mesh staging, single-copy uniform outputs, uniform varying packing, dense output layout, dead-array cleanup and lossless internal integer index compression. It also uses fragment wave32, a mesh late-allocation cap of16 and the final packed-decode lifetime experiment. Original shader floating-point precision and safety synchronization remain; compact vertices, native TASK and compute CU-mode experiments remain disabled. Application TASK still uses the hybrid path when encountered; this profile does not claim to make it stable under unrestricted routing.

The user observed about97 FPS in a Control Resonant comparison scene versus about91 with compute-to-graphics containment. This is game-specific playtest feedback, not a controlled benchmark, universal uplift or long-session stability proof. No captured application TASK workload established a benefit. Shader-cache state and workload differ between some historical comparisons.

## Requirements and installation

Linux x86_64, physical BC250/GFX1013, native Steam, compatible BC250 kernel/firmware and the same native driver dependencies as R2. Python3.11+, Bash/coreutils and the tested **Proton11.0-2c** distribution (`proton-11.0-2c-x86_64`) must already be installed. No kernel/firmware installation or system-driver replacement is performed. Other Proton versions, Flatpak and32-bit games are not qualified.

Download `bc250-performance-linux-x86_64.tar.gz` and `SHA256SUMS` from the performance prerelease, then:

```bash
sha256sum --ignore-missing -c SHA256SUMS
tar -xzf bc250-performance-linux-x86_64.tar.gz
cd bc250-performance-linux-x86_64
bash install.sh --proton-base "$HOME/.local/share/Steam/steamapps/common/Proton 11.0"
```

Use your actual Proton directory. The installer verifies it, creates a private compatibility-tool copy and checks payload hashes/native dependencies. Existing destinations are refused. It does not overwrite R2, system Mesa, original Proton or game settings.

Restart Steam, select **BC250 Performance (experimental)** under the chosen game's Compatibility settings, and use the exact command printed by the installer:

```text
"/home/YOUR_USERNAME/.local/bin/bc250-performance" %command%
```

MangoHud FPS/frametime is enabled when installed; `BC250_FPS_OVERLAY=0` disables it. `bc250-performance --check` verifies the installed artifacts without launching a game. Native Vulkan tests can use `bc250-performance --native executable`; the D3D12 queue policy does not apply to native Vulkan applications.

## Borderlands and recovery

**Do not use this profile for Borderlands4.** Its Steam appID1285190 is refused with instructions to use R2. This is a known-game safeguard, not a general workload classifier. For other games needing containment, explicitly choose R2; switching only an environment variable does not recreate the R2 driver.

Select **BC250 R2 (experimental)** and use its original command:

```text
"/home/YOUR_USERNAME/.local/bin/bc250-r2" %command%
```

R2 retains its original binary, compute-to-graphics policy, hybrid TASK and limitations. It is the preserved recovery option, not a newly certified fix for all hybrid workloads.

On26September, R4, the older92FPS Control baseline, and R4 with newer selectable policies disabled all produced Borderlands graphics-queue timeouts. The disabled-policy run first reached a54FPS menu, then hung later. That menu success is not a stability pass. A separate R2 exit was explained by the game's patch/restart bug, so it is not evidence of a driver crash or completed stability qualification. Memory exhaustion and the initiating GPU defect remain unproved.

## Rollback, source and validation

Remove this launch option and select ordinary Proton to use the system driver. To uninstall this profile only, run `python3 install.py --uninstall` from the bundle, with the original custom path arguments if any. Close games first. R2 and caches are retained.

See `VALIDATION.md`, `BUILD.md`, `manifest.json`, source patch and source archive. The performance Mesa binary is the preserved artifact `67fc476a...`, not an untested rebuild. vkd3d is byte-identical to R2 (`1dd2de...`); corresponding source remains in the R2 source asset. Heavy diagnostic DLLs are not packaged. Source contains dormant experimental instrumentation, which is not enabled by this launcher.
