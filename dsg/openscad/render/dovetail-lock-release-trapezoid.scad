// Actual HUB75 baseline detachable clamp with trapezoid male lock release.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>

profile = "medium";
taper_angle = 45;

dovetail =
    hub75_tube_mount_dovetail_create_for_size(
        profile,
        lock_release_shape = "trapezoid",
        lock_release_taper_angle = taper_angle
    );

clamp =
    hub75_tube_clamp_create(
        dovetail = dovetail
    );

$vpt = hub75_lab_development_camera_target();
$vpr = hub75_lab_development_camera_rotation();
$vpd = hub75_lab_development_camera_distance_single();

hub75_lab_tube_clamp_baseline(
    clamp,
    high_resolution = true,
    part_color = [0.88, 0.08, 0.05, 1]
);
