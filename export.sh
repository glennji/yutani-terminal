#!/bin/sh
# Export every printable part of terminal.scad, in print orientation, one file per part.
#   ./export.sh          STL files into ./stl
#   ./export.sh 3mf      3MF files into ./3mf
# Set OPENSCAD to override the OpenSCAD binary (needs a build with the manifold backend).

set -eu
cd "$(dirname "$0")"

fmt="${1:-stl}"
out="./$fmt"
openscad="${OPENSCAD:-$(command -v openscad || echo /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD)}"

# part:quantity to print
parts="base_FL:1 base_FR:1 base_RL:1 base_RR:1
plate_FL:1 plate_FR:1 plate_RL:1 plate_RR:1
pod_BL:1 pod_BR:1 pod_TL:1 pod_TR:1
hatch_L:1 hatch_R:1
gasket_L:1 gasket_R:1
visor:2 trim_strip:2 clamp_tab:16
cam_body:1 cam_cap:1 cam_cradle:1
island_L:1"

mkdir -p "$out"
failed=0
for entry in $parts; do
    part="${entry%%:*}"
    qty="${entry##*:}"
    file="$out/$part.$fmt"
    log="$out/$part.log"
    printf '%-12s x%-3s ' "$part" "$qty"
    if "$openscad" --backend=manifold -D "part=\"$part\"" -o "$file" terminal.scad >"$log" 2>&1 \
        && ! grep -qiE '^(WARNING|ERROR)' "$log"; then
        echo "ok"
        rm -f "$log"
    else
        echo "FAILED (see $log)"
        failed=1
    fi
done
exit $failed
