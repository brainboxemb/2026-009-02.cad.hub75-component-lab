use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium"),
    transition_relief_radius = 10.0,
    transition_relief_bite = 1.0,
    transition_relief_face_depth = 2.0
);

$vpt = [0, -3.5, 10];
$vpr = [65, 0, 25];
$vpd = 72;

hub75_tube_clamp_build(
    clamp,
    use_tension_bore = false,
    high_resolution = true,
    apply_transition_relief = true
);
