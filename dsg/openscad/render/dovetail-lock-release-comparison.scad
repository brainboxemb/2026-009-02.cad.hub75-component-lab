// Actual HUB75 baseline detachable clamp comparison.
//
// Left  = released rectangular male lock-release opening
// Right = candidate trapezoid male lock-release opening
//
// Everything except the release-opening profile is identical.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>

PROFILE = "medium";
TAPER_ANGLE_DEG = 45;
SPACING_MM = 28;

function _dovetail(shape) =
    hub75_tube_mount_dovetail_create_for_size(
        PROFILE,
        lock_release_shape = shape,
        lock_release_taper_angle_deg =
            TAPER_ANGLE_DEG
    );

function _clamp(shape) =
    hub75_tube_clamp_create(
        dovetail = _dovetail(shape)
    );

$vpt = hub75_lab_development_camera_target();
$vpr = hub75_lab_development_camera_rotation();
$vpd = 145;

translate([-SPACING_MM / 2, 0, 0])
    hub75_lab_tube_clamp_baseline(
        _clamp("rectangular"),
        high_resolution = true,
        part_color = [0.72, 0.72, 0.72, 1]
    );

translate([SPACING_MM / 2, 0, 0])
    hub75_lab_tube_clamp_baseline(
        _clamp("trapezoid"),
        high_resolution = true,
        part_color = [0.88, 0.08, 0.05, 1]
    );
