// STL export of the confirmed lab candidate in development orientation.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium")
);

hub75_lab_tube_clamp_candidate(
    clamp,
    radius = 5,
    bite = 1,
    depth = 2,
    use_tension_bore = true,
    high_resolution = true
);
