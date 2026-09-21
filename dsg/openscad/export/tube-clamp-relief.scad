// Diagnostic phase: STL remains the unmodified baseline in development orientation.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium")
);

hub75_lab_tube_clamp_baseline(
    clamp,
    use_tension_bore = true,
    high_resolution = true
);
