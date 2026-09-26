#!/usr/bin/env bash
# Experimental R2 recovery policy. Does not modify game configuration files.
set -euo pipefail
root=$(dirname "$(readlink -f "$0")")
proton=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["proton"])' "$root/config.json")
python3 - "$root" "$proton" <<'PY'
import hashlib,json,pathlib,sys
r=pathlib.Path(sys.argv[1]); m=json.loads((r/'manifest.json').read_text())
for path,key in [(r/'libvulkan_radeon.so','payload/libvulkan_radeon.so'),(pathlib.Path(sys.argv[2]).parent/'files/lib/wine/vkd3d-proton/x86_64-windows/d3d12core.dll','payload/d3d12core.dll')]:
 with path.open('rb') as f: h=hashlib.file_digest(f,'sha256').hexdigest()
 if h!=m['payload_sha256'][key]: raise SystemExit('BC250 Performance integrity check failed: '+str(path))
PY
if [[ ${1:-} == --check ]]; then
    printf 'BC250 Performance: driver and patched DLL verified\nProton: %s\nPolicy: normal routing; experimental R4; compact vertices OFF\n' "$proton"
    exit 0
fi
native=false
if [[ ${1:-} == --native ]]; then native=true; shift; fi
(( $# )) || { echo 'Usage: bc250-performance %command% (Steam), or bc250-performance --native executable' >&2; exit 2; }
if ! $native; then
    selected=false
    for arg in "$@"; do
        if [[ -f $arg && ${arg##*/} == proton && $(readlink -f "$arg") == $(readlink -f "$proton") ]]; then selected=true; fi
    done
    $selected || { echo 'Select BC250 Performance (experimental) under Steam > game Properties > Compatibility, then relaunch.' >&2; exit 2; }
fi
export RADV_BC250_NATIVE_TASK=0 RADV_BC250_HYBRID_TASK=1
export BC250_EXPERIMENTAL_COMPUTE_CU_MODE=false
export BC250_BALANCED_SLICES=true BC250_SINGLE_PIECE=true
export BC250_CACHE_PLAN=true BC250_TRANSIENT_ARENA=true
export BC250_PARALLEL_CULL=true BC250_COMPACT_VERTICES=false BC250_OUTPUT_REGIONS=true
export BC250_EXPERIMENTAL_PRIVATE_GTT=true
export RADV_BC250_MESH_ONCE=false BC250_EXPERIMENTAL_ZEROED_PRIVATE_GTT=false
export RADV_PERFTEST=mesh,nircache
export BC250_EXPERIMENTAL_DIRECT_SPLIT=true BC250_EXPERIMENTAL_SKIP_INACTIVE_CHUNKS=true
export RADV_BC250_SPLIT_MESH=true RADV_BC250_EXPAND_PRIMITIVES=true
export BC250_EXPERIMENTAL_CULL_COMPACT=true BC250_EXPERIMENTAL_PACK_TRIANGLE_VERTICES=true BC250_EXPERIMENTAL_POST_MESH_VGT_FLUSH=1
export VKD3D_BC250_ALLOW_MESH_WITHOUT_BARYCENTRICS=1 VKD3D_BC250_QUEUE_PROBE=observe
export VK_DRIVER_FILES="$root/icd.json" VK_ICD_FILENAMES="$root/icd.json"
unset VKD3D_FEATURE_LEVEL RADV_DEBUG BC250_NATIVE_TASK_COMPILE BC250_NATIVE_TASK_DIRECT BC250_NATIVE_TASK_INDIRECT
unset BC250_CHAIN_TRACE BC250_CHAIN_SHADER_ONLY BC250_CHAIN_ARGUMENTS_ONLY BC250_INPUT_TRACE BC250_INPUT_CODE_ONLY
unset BC250_TRACE_COMPILE BC250_TRACE_NATIVE_TASK BC250_TRACE_USAGE BC250_CAPTURE_SHADER_CODE BC250_CAPTURE_POLICY
unset BC250_SKIP_DRAW BC250_RECORD_ONLY BC250_DIAGNOSTIC_MESH_STATE_ONLY BC250_DIAGNOSTIC_OMIT_LAUNCH
unset BC250_DIAGNOSTIC_ZERO_SCISSOR BC250_DIAGNOSTIC_RASTER_DISCARD BC250_USAGE_DIAG BC250_EXPERIMENTAL_PRIM_FIRST BC250_EXPERIMENTAL_PRELOAD_EXPORTS
export BC250_CAPTURE_RAW_IBS=false BC250_CAPTURE_MESH_CODE=false
export PROTON_LOG=0 WINEDEBUG=-all VKD3D_DEBUG=none VKD3D_SHADER_DEBUG=none
export MESA_SHADER_CACHE_DISABLE=false
appid=${SteamAppId:-${SteamGameId:-native}}
[[ $appid =~ ^[0-9]+$ ]] || appid=native
export MESA_SHADER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bc250-performance/$appid/mesa"
export VKD3D_SHADER_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/bc250-performance/$appid/vkd3d"
mkdir -p "$MESA_SHADER_CACHE_DIR" "$VKD3D_SHADER_CACHE_PATH"
export MANGOHUD=${BC250_FPS_OVERLAY:-1}
if [[ $MANGOHUD == 1 ]] && ! command -v mangohud >/dev/null; then
    echo 'MangoHud is not installed; FPS overlay disabled. Install MangoHud to enable it.' >&2
    export MANGOHUD=0
fi
export MANGOHUD_CONFIGFILE=/dev/null MANGOHUD_CONFIG='fps,frametime,gpu_stats=0,cpu_stats=0,permit_upload=0'
# Explicit per-game selection; no automatic shader-stage detection.
if [[ ${SteamAppId:-${SteamGameId:-}} == 1285190 ]]; then
    echo 'Borderlands 4: use the preserved BC250 R2 compatibility tool and bc250-r2 launch command.' >&2
    exit 2
fi
export BC250_R3=true
export BC250_UNIFORM_OUTPUT=1 BC250_UNIFORM_PACKING=1
export BC250_DIRECT_READ=1 BC250_DIRECT_UNIFORM=1
export BC250_EXPERIMENTAL_DENSE_OUTPUTS=true
export BC250_MESH_LATE_ALLOC_CAP=16 RADV_PERFTEST=mesh,nircache,pswave32
export BC250_BALANCED_SLICES=false BC250_EXPORT_VECTOR=0
export BC250_PS_PRESSURE=0 BC250_MESH_PRESSURE=0 BC250_LIFETIME=0 BC250_ALU_LIFETIME=1
unset VKD3D_SHADER_OVERRIDE VK_LOADER_LAYERS_DISABLE DISABLE_MANGOHUD ACO_DEBUG
unset RADV_THREAD_TRACE RADV_THREAD_TRACE_TRIGGER RADV_THREAD_TRACE_BUFFER_SIZE
unset BC250_INPUT_TRACE BC250_SEMAPHORE_TRACE BC250_INPUT_DELAY_SECONDS BC250_INPUT_FOCUS BC250_INPUT_WRITERS BC250_INPUT_DUMP_DIR BC250_CAPTURE_POLICY_SHADERS BC250_LIFETIME_TRACE
if [[ $MANGOHUD == 1 ]]; then export VK_LOADER_LAYERS_ENABLE=VK_LAYER_MANGOHUD_overlay_x86_64; fi
exec "$@"
