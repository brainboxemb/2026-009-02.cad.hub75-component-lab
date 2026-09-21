// Target calibration in development orientation.
// Baseline stays intact; green is the proposed low R10 cylinder location.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium")
);

$vpt = hub75_lab_development_camera_target();
$vpr = hub75_lab_development_camera_rotation();
$vpd = hub75_lab_development_camera_distance_single();

hub75_lab_tube_clamp_baseline(
    clamp,
    use_tension_bore = false,
    high_resolution = true,
    part_color = [0.72, 0.72, 0.72, 1]
);

hub75_lab_tube_clamp_relief_probe(
    clamp,
    radius = 5,
    depth = 2,
    high_resolution = true
);
