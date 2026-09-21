// Stable before/after evidence in development orientation.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium")
);

spacing = 18;

$vpt = hub75_lab_development_camera_target();
$vpr = hub75_lab_development_camera_rotation();
$vpd = hub75_lab_development_camera_distance_comparison();

translate([-spacing / 2, 0, 0])
    hub75_lab_tube_clamp_baseline(
        clamp,
        use_tension_bore = false,
        high_resolution = true
    );

translate([spacing / 2, 0, 0])
    hub75_lab_tube_clamp_candidate(
        clamp,
        radius = 6,
        bite = 0.4,
        z_height = 4,
        z_offset = 1,
        use_tension_bore = false,
        high_resolution = true
    );
