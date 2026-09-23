// File: corner-edge-clamp-dovetail.scad
//   XY section through the installed female dovetail profile.
//   Gray is retained core material; red is the material removed by the female
//   interface cutter.

use <../ext/lib.scad.forge/openscad/resolution.scad>
use <../lab_components/corner_edge_clamp_lab.scad>

$vpr = [0, 0, 0];
$vpt = [12, 0, 10];
$vpd = 110;

hub75_lab_corner_edge_clamp_view(
    side = "left",
    size = "medium",
    view = "dovetail_profile",
    explode_distance_mm = 0,
    show_tube = false,
    resolution = FG_RES_HIGH()
);
