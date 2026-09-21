# Validation and limits

## Driver evidence predating packaging

- R1: full NIR suite reported 6,204 passes, nine disabled. Do not attribute this as a full R2 suite run.
- R2 original combined fixture matrix: 120 passes across off/on/warm-on/off configurations. These original tests included compact vertices; that policy later failed a game and is disabled in the release.
- Parallel cull: 28 forced 64/128-lane cases.
- Shared-vertex grid: 12 R1/R2 runs and six paired byte-identical frames. These did not establish game safety of compact mapping.
- Pipeline-cache import/export and compile-required cases; six concurrent pipeline creations and surviving sibling replacement.
- Sixteen indirect draws used one transient arena page with disjoint suballocations; the post-commit runtime passed that smoke test.
- Targeted output arithmetic fixture demonstrated eligible ALU moved under slice guards. This is not a measured general FPS gain.
- vkd3d selective routing: queue creation passed 40 assertions. Three upstream tests across four modes passed 12 cases, including graphics/compute synchronization and pixel-checked COPY/COMPUTE render-target operations. These are not a complete game resource-lifetime reproducer.

## Game observations

The original all-five R2 policy hung Borderlands twice according to the tester. Compact vertices reproduced context loss in an isolated policy test. The recovery policy used here keeps compact vertices off; it reached a visible Borderlands menu through the installed launcher. One surviving menu observation later reported two SMU metrics-table errors while graphics completion continued. Sustained stability is not certified.

The tester reported near-fallback performance for an earlier optimization candidate (58 versus 61 FPS in a menu and similar gameplay), but that is user-reported context, not a controlled benchmark proving R2 uplift. Different games and paths showed different results; an Alan Wake 2 comparison favored fallback. No universal game speedup claim is made.

On September 21, a bounded preserved-R2 control reproduced framebuffer pin `-12` with substantial system RAM available. It was intentionally stopped while the board remained reachable. This known memory issue is documented rather than suppressed. The later zeroed-GTT experiment is a separate unshipped candidate.

## Packaging validation

`RELEASE-TESTS.md` records installer/launcher and payload validation performed specifically for this release. Earlier driver tests do not substitute for testing the installer. Exact binary checksums are in `manifest.json`.

Not established: Vulkan conformance, all descriptor layouts, exhaustive OOM/command-buffer-lifetime behavior, all mesh outputs, 32-bit games, unmodified kernels, arbitrary Proton versions, or elimination of the original queue-dependent hang.
