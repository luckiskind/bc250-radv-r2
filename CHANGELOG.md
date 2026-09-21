# R2 recovery release

Release `r2-20260921` packages Mesa source `424ccf62d2247ad9aff09195e95dac6ff6c4db9f` and vkd3d source `3dc6c269a9eaa66aca6b5e6ff958326a3bcffcb0`. Release packaging changes paths, installation and documentation; it does not replace the tested driver binary with a new compiler build.

## Baseline and earlier work

Credit [lonewolf0622’s BC250 mesh patch](https://github.com/lonewolf0622/BC-250-Mesh-Shader-Patch---driconf-Edition-opt-in-per-application-) for the baseline groundwork. R2 is a separate continuation with substantial later Mesa and vkd3d development.

- Native GFX1013 mesh enablement and preservation of fast-launch vertex grouping.
- Experimental application TASK lowering into compute producers, payload storage and native mesh consumers; preservation of application descriptors, push constants and draw identity.
- GPU-generated indirect dispatch setup, zero-count handling and chunked workloads.
- Restricted primitive-attribute expansion and cull handling to work around BC250 export limitations. Query support was explored historically but is not universally advertised in split mode.
- Bounded primitive replay splitting for larger mesh outputs; opt-in triangle packing and fully-culled handling.
- Native mesh-only direct dispatch and independently cached shared argument helpers. These avoid synthetic TASK overhead for eligible mesh-only draws.
- Proven primitive-count bounds, preservation of ordinary mesh shader caching, and direct primitive-slice writes.
- Transient scratch lifetime corrections, indirect command-space reservation and inactive-chunk skipping.
- Physical GFX1013 async queue foundation; later investigation retained ordinary COMPUTE-to-graphics routing as the release workaround. Experimental native TASK is present in the source but disabled by this release policy.

## R1 improvements retained

- Correct normalized signed min/max handling in NIR primitive-count analysis.
- Cull/triangle-packing policy in compiler cache identity.
- Original-NIR cache identity includes sparse descriptor layouts, layout hashes and set count rather than pointer identity.
- Independent deserialized original-NIR reuse in eligible preparation paths.
- Balanced split capacities without changing the child count or 63-primitive ceiling.
- Native single-piece shortcut for proven output bounds at or below 63 primitives.

## R2 policies

| Policy | Release setting | Purpose |
|---|---|---|
| Preparation records/cache | On | Restore split metadata alongside executable shaders and skip repeated preparation on complete hits. |
| Transient arena | On, restricted eligibility | Disjoint small allocations from command-buffer-owned pages; lifetime ends at reset/destruction. |
| Parallel culling | On, restricted eligibility | Parallel stable compaction where the workgroup covers the child capacity. |
| Output regions | On, restricted eligibility | Guard repeated eligible pure output arithmetic by the owning slice. |
| Compact vertices | **Off** | Isolated policy reproduced Borderlands context loss; reverting this setting restored menu operation. |
| Native TASK | **Off** | Unqualified for normal release use; hybrid TASK retained. |
| Compute CU-mode experiment | **Off** | Did not replace the queue-routing workaround. |

## Deliberately excluded later experiments

The compute-once/output-materialization experiment, its scalar-component extension, the later zeroed-private-GTT placement extension, aggressive FP16, and adaptive compiler experiments are not part of the R2 binary. Compute-once was reported at 18 FPS by the tester and is not a release performance improvement. A short successful memory trial is not grounds to silently combine that experiment into R2.

This is a curated change description. The cumulative patches and complete source snapshots are the authoritative code, including dormant diagnostics. Historical reverted ideas are not presented as active fixes.
