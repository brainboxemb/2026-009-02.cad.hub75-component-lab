// File: corner-edge-clamp-tube-keepout.scad
//   Ø10 tube keep-out highlighted inside the core corner body.

use <../ext/lib.scad.forge/openscad/resolution.scad>
use <../lab_components/corner_edge_clamp_lab.scad>

$vpr = [68, 0, 35];
$vpt = [18, 1.5, -10];
$vpd = 220;

hub75_lab_corner_edge_clamp_view(
    side = "left",
    size = "medium",
    view = "tube_keepout",
    explode_distance_mm = 0,
    show_tube = true,
    resolution = FG_RES_HIGH()
);
