// STL export of the current isolated clamp-relief candidate.

use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium"),
    transition_relief_radius = 10.0,
    transition_relief_bite = 1.0,
    transition_relief_face_depth = 2.0
);

hub75_tube_clamp_build(
    clamp,
    use_tension_bore = true,
    high_resolution = true,
    apply_transition_relief = true
);
