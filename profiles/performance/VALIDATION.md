# Performance profile qualification

## Game observations

- Control Resonant: user reported approximately97FPS with normal routing, versus approximately91 with routed R4, in their comparison scene; no immediate hang reported. Not a long-duration or controlled benchmark.
- Prior staged optimizations: direct reads improved user-observed86→87–88FPS; cleanup/index16 combination later reached92. Individual attribution and cross-game gains are not established.
- Alan Wake2: user reported improved R4 performance. Normal-routing performance-profile qualification is not established by that observation.
- Borderlands4: excluded. R4 and preserved92FPS baseline failed with graphics timeouts. Newer-policies-off reached54FPS menu and subsequently failed too. R2 remains the preserved recovery choice with existing warnings.
- No universal native TASK, hybrid TASK, unrestricted async, Vulkan/D3D conformance, or memory-stability claim.

## Compiler and fixture evidence

R3 had63 final fixture checks and6204 NIR CPU tests passing, with scope limitations recorded in development notes. Subsequent direct-read/uniform/packing/index changes passed bounded paired-image and compiler checks. Index255/partial-write coverage remained incomplete. Cold/warm creation success alone is not proof of cache hits. Latest packed/ACO lifetime changes reduced selected pre-scheduler PS pressure137→133, but allocated VGPRs stayed144; no occupancy gain proved.

## Packaging checks

See `RELEASE-TESTS.md` for checks actually executed on this package. Packaging validation does not submit game GPU work. The new installed entry point must not be described as newly game-qualified simply because its policies match a prior playtest.

R2 files and release assets are not replaced. Experimental performance selection is explicit; known Borderlands appID is refused. No automatic detection/rerouting of individual hybrid draws is implemented.
