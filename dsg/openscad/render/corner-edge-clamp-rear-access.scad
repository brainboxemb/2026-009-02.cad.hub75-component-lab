// File: corner-edge-clamp-rear-access.scad
//   Additional rear-face opening used only to make the clamp cavity printable.

use <../ext/lib.scad.forge/openscad/resolution.scad>
use <../lab_components/corner_edge_clamp_lab.scad>

$vpr = [68, 0, 35];
$vpt = [18, 1.5, -10];
$vpd = 220;

hub75_lab_corner_edge_clamp_view(
    side = "left",
    size = "medium",
    view = "rear_access",
    explode_distance_mm = 0,
    show_tube = false,
    resolution = FG_RES_HIGH()
);
