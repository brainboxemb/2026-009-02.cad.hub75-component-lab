// Close-up in development orientation:
// resulting clamp in grey, removed relief volume in red.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium"),
    transition_relief_radius = 10.0,
    transition_relief_bite = 1.0,
    transition_relief_face_depth = 2.0
);

module clamp_geometry(apply_relief, part_color) {
    hub75_lab_development_orientation()
        hub75_tube_clamp_build(
            clamp,
            part_color = part_color,
            use_tension_bore = false,
            high_resolution = true,
            apply_transition_relief = apply_relief
        );
}

$vpt = [0, 10, 0];
$vpr = [55, 0, 35];
$vpd = 72;

// Final candidate.
clamp_geometry(true, [0.72, 0.72, 0.72, 1]);

// Material present in the baseline but removed by the candidate relief.
color([0.90, 0.08, 0.05, 1])
    difference() {
        clamp_geometry(false, [1, 1, 1, 1]);
        clamp_geometry(true, [1, 1, 1, 1]);
    }
