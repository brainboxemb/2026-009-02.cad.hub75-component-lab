// File: corner-edge-clamp-clamp-access.scad
//   Clamp insertion/access removal after tube and dovetail cuts are excluded.

use <../ext/lib.scad.forge/openscad/resolution.scad>
use <../lab_components/corner_edge_clamp_lab.scad>

$vpr = [68, 0, 35];
$vpt = [18, 1.5, -10];
$vpd = 220;

hub75_lab_corner_edge_clamp_view(
    side = "left",
    size = "medium",
    view = "clamp_access",
    explode_distance_mm = 0,
    show_tube = true,
    resolution = FG_RES_HIGH()
);
