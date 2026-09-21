// Development-orientation close-up:
// candidate in grey, removed material in red.

use <../lab_components/tube_clamp_relief_candidate.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium")
);

$vpr = [55, 0, 35];

hub75_lab_tube_clamp_candidate(
    clamp,
    radius = 10,
    bite = 1,
    depth = 2,
    use_tension_bore = false,
    high_resolution = true,
    part_color = [0.72, 0.72, 0.72, 1]
);

color([0.90, 0.08, 0.05, 1])
    difference() {
        hub75_lab_tube_clamp_baseline(
            clamp,
            use_tension_bore = false,
            high_resolution = true,
            part_color = [1, 1, 1, 1]
        );

        hub75_lab_tube_clamp_candidate(
            clamp,
            radius = 10,
            bite = 1,
            depth = 2,
            use_tension_bore = false,
            high_resolution = true,
            part_color = [1, 1, 1, 1]
        );
    }
