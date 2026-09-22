// File: corner-edge-clamp-access.scad
//   YZ section through the clamp/interface centre.
//   Gray is retained tube-mount body, blue is tube keep-out and red is the
//   additional clamp insertion/access removal after tube/dovetail clearance.

use <../ext/lib.scad.forge/openscad/resolution.scad>
use <../lab_components/corner_edge_clamp_lab.scad>

$vpr = [90, 0, 90];
$vpt = [0, -1, 10];
$vpd = 105;

hub75_lab_corner_edge_clamp_view(
    side = "left",
    size = "medium",
    view = "access_section",
    explode_distance_mm = 0,
    show_tube = false,
    resolution = FG_RES_HIGH()
);
