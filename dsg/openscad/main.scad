// HUB75 component-lab workbench.
//
// Active experiment: corner-edge clamp integration.
// Scope and frozen parent baseline:
//   docs/00-corner-edge-clamp-integration.md

use <ext/lib.scad.forge/openscad/resolution.scad>
use <lab_components/corner_edge_clamp_lab.scad>

/* [Corner-edge lab] */
c_view = "assembly"; // [core,tube_mount,assembly,exploded]
d_side = "left"; // [left,right]
d_size = "medium"; // [small,medium,large]
c_show_tube = true;
c_explode_distance_mm = 18;
c_resolution = "high"; // [low,high]

function _hub75_lab_active_resolution(name) =
    name == "low"
        ? FG_RES_LOW()
        : FG_RES_HIGH();

$vpr = [70, 0, 35];
$vpt = [0, 0, 12];
$vpd = 220;

hub75_lab_corner_edge_clamp_view(
    side = d_side,
    size = d_size,
    view = c_view,
    explode_distance_mm = c_explode_distance_mm,
    show_tube = c_show_tube,
    resolution = _hub75_lab_active_resolution(c_resolution)
);
