// Actual HUB75 baseline detachable clamp with trapezoid male lock release.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>

PROFILE = "medium";
TAPER_ANGLE_DEG = 45;

_dovetail =
    hub75_tube_mount_dovetail_create_for_size(
        PROFILE,
        lock_release_shape = "trapezoid",
        lock_release_taper_angle_deg =
            TAPER_ANGLE_DEG
    );

_clamp =
    hub75_tube_clamp_create(
        dovetail = _dovetail
    );

$vpt = hub75_lab_development_camera_target();
$vpr = hub75_lab_development_camera_rotation();
$vpd = hub75_lab_development_camera_distance_single();

hub75_lab_tube_clamp_baseline(
    _clamp,
    high_resolution = true,
    part_color = [0.88, 0.08, 0.05, 1]
);
