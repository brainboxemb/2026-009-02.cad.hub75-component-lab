// HUB75 component-lab workbench.
// Geometry is shown in the standardized development orientation.

use <lab_components/tube_clamp_relief_candidate.scad>
use <project_components/tube_mount/tube_mount_interface.scad>

/* [Profile] */
profile = "medium"; // [small,medium,large]

/* [View] */
view = "comparison"; // [relief,baseline,comparison,removed]
bore = "functional"; // [functional,tension]

/* [Transition relief] */
relief_radius = 10.0;
relief_bite = 1.0;
relief_depth = 2.0;

/* [Preview] */
high_resolution = false;
comparison_spacing = 18;

$vpt = hub75_lab_development_camera_target();
$vpr = hub75_lab_development_camera_rotation();
$vpd =
    view == "comparison"
        ? hub75_lab_development_camera_distance_comparison()
        : hub75_lab_development_camera_distance_single();

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size(profile)
);

use_tension_bore = bore == "tension";

module baseline(part_color) {
    hub75_lab_tube_clamp_baseline(
        clamp,
        use_tension_bore = use_tension_bore,
        high_resolution = high_resolution,
        part_color = part_color
    );
}

module candidate(part_color) {
    hub75_lab_tube_clamp_candidate(
        clamp,
        radius = relief_radius,
        bite = relief_bite,
        depth = relief_depth,
        use_tension_bore = use_tension_bore,
        high_resolution = high_resolution,
        part_color = part_color
    );
}

if (view == "baseline")
    baseline([0.72, 0.72, 0.72, 1]);
else if (view == "relief")
    candidate([0.88, 0.08, 0.05, 1]);
else if (view == "removed")
    color([0.92, 0.12, 0.05, 1])
        difference() {
            baseline([1, 1, 1, 1]);
            candidate([1, 1, 1, 1]);
        }
else {
    translate([-comparison_spacing / 2, 0, 0])
        baseline([0.72, 0.72, 0.72, 1]);

    translate([comparison_spacing / 2, 0, 0])
        candidate([0.88, 0.08, 0.05, 1]);
}
