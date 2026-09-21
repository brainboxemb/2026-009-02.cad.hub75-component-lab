// HUB75 component-lab workbench.
use <project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>

/* [Profile] */
profile = "medium"; // [small,medium,large]

/* [View] */
view = "comparison"; // [relief,baseline,comparison,removed]
bore = "functional"; // [functional,tension]

/* [Transition relief] */
relief_radius = 10.0;
relief_bite = 1.0;
relief_face_depth = 2.0;

/* [Preview] */
high_resolution = false;
comparison_spacing = 18;

clamp = hub75_tube_clamp_create(
    dovetail = hub75_tube_mount_dovetail_create_for_size(profile),
    transition_relief_radius = relief_radius,
    transition_relief_bite = relief_bite,
    transition_relief_face_depth = relief_face_depth
);

use_tension_bore = bore == "tension";

module clamp_view(apply_relief, part_color) {
    hub75_tube_clamp_build(
        clamp,
        part_color = part_color,
        use_tension_bore = use_tension_bore,
        high_resolution = high_resolution,
        apply_transition_relief = apply_relief
    );
}

if (view == "baseline")
    clamp_view(false, [0.72, 0.72, 0.72, 1]);
else if (view == "relief")
    clamp_view(true, [0.88, 0.08, 0.05, 1]);
else if (view == "removed")
    color([0.92, 0.12, 0.05, 1])
        difference() {
            clamp_view(false, [1, 1, 1, 1]);
            clamp_view(true, [1, 1, 1, 1]);
        }
else {
    translate([-comparison_spacing / 2, 0, 0])
        clamp_view(false, [0.72, 0.72, 0.72, 1]);
    translate([comparison_spacing / 2, 0, 0])
        clamp_view(true, [0.88, 0.08, 0.05, 1]);
}
