// File: corner-edge-clamp-print.scad
//   Tube-mount corner in the same rear-face-down orientation as production STL export.

use <../ext/lib.scad.forge/openscad/resolution.scad>
use <../lab_components/corner_edge_clamp_lab.scad>

$vpr = [58, 0, 35];
$vpt = [16, -8, 4];
$vpd = 230;

hub75_lab_corner_edge_clamp_view(
    side = "left",
    size = "medium",
    view = "print_orientation",
    explode_distance_mm = 0,
    show_tube = false,
    resolution = FG_RES_HIGH()
);
