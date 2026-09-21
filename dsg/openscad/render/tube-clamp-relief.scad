// Stable before/after evidence in development orientation.

use <../lab_components/tube_clamp_relief_candidate.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium")
);

spacing = 18;

$vpr = [55, 0, 35];

translate([-spacing / 2, 0, 0])
    hub75_lab_tube_clamp_baseline(
        clamp,
        use_tension_bore = false,
        high_resolution = true
    );

translate([spacing / 2, 0, 0])
    hub75_lab_tube_clamp_candidate(
        clamp,
        radius = 10,
        bite = 1,
        depth = 2,
        use_tension_bore = false,
        high_resolution = true
    );
