// Development-orientation close-up:
// candidate in grey, material removed by the confirmed cutter in red.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../lab_components/tube_clamp_relief_candidate.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size("medium")
);

$vpt = hub75_lab_development_camera_target();
$vpr = hub75_lab_development_camera_rotation();
$vpd = hub75_lab_development_camera_distance_single();

hub75_lab_tube_clamp_candidate(
    clamp,
    radius = 6,
    bite = 0.4,
    z_height = 4,
        z_offset = 1,
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
            radius = 6,
            bite = 0.4,
            z_height = 4,
        z_offset = 1,
            use_tension_bore = false,
            high_resolution = true,
            part_color = [1, 1, 1, 1]
        );
    }
