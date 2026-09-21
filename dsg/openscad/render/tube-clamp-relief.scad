// Stable before/after evidence in development orientation.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium"),
    transition_relief_radius = 10.0,
    transition_relief_bite = 1.0,
    transition_relief_face_depth = 2.0
);

spacing = 18;

$vpt = [0, 10, 0];
$vpr = [55, 0, 35];
$vpd = 115;

module development_clamp(apply_relief, part_color) {
    hub75_lab_development_orientation()
        hub75_tube_clamp_build(
            clamp,
            part_color = part_color,
            use_tension_bore = false,
            high_resolution = true,
            apply_transition_relief = apply_relief
        );
}

translate([-spacing / 2, 0, 0])
    development_clamp(false, [0.72, 0.72, 0.72, 1]);

translate([spacing / 2, 0, 0])
    development_clamp(true, [0.88, 0.08, 0.05, 1]);
