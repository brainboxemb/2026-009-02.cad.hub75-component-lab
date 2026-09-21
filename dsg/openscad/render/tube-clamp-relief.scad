// Stable before/after evidence for the current clamp-relief candidate.

use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium"),
    transition_relief_radius = 10.0,
    transition_relief_bite = 1.0,
    transition_relief_face_depth = 2.0
);

spacing = 18;

$vpt = [0, -3.5, 10];
$vpr = [65, 0, 25];
$vpd = 115;

translate([-spacing / 2, 0, 0])
    hub75_tube_clamp_build(
        clamp,
        part_color = [0.72, 0.72, 0.72, 1],
        use_tension_bore = false,
        high_resolution = true,
        apply_transition_relief = false
    );

translate([spacing / 2, 0, 0])
    hub75_tube_clamp_build(
        clamp,
        part_color = [0.88, 0.08, 0.05, 1],
        use_tension_bore = false,
        high_resolution = true,
        apply_transition_relief = true
    );
