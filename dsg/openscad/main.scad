// HUB75 component-lab workbench.
//
// Use 'experiment' to switch between the current relief work and the released
// tube-clamp tension behavior.

use <lab_orientation.scad>
use <ext/lib.scad.clamps/openscad/tube-clamp/tube_clamp.scad>
use <project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <project_components/tube_mount/tube_mount_interface.scad>
use <lab_components/tube_clamp_relief_candidate.scad>

/* [Lab] */
experiment = "relief"; // [relief,tension]

/* [Profile] */
profile = "medium"; // [small,medium,large]

/* [Relief view] */
view = "comparison"; // [relief,baseline,comparison,removed]
bore = "functional"; // [functional,tension]

/* [Transition relief] */
relief_radius = 6.0;
relief_bite = 0.4;
relief_z_height = 4.0;
relief_z_offset = 1.0;

/* [Tension experiment] */
tension_view = "comparison"; // [functional,tension,comparison]
tension_display = "profile_2d"; // [profile_2d,model_3d]
tension_diameter = 9.6;
tension_comparison_spacing = 18;

/* [Preview] */
high_resolution = false;
comparison_spacing = 18;

hub75_clamp = hub75_tube_clamp_create(
    tension_diameter = tension_diameter,
    dovetail = hub75_tube_mount_dovetail_create_for_size(profile)
);

base_clamp = hub75_clamp.base_clamp;
use_tension_bore = bore == "tension";

// ----------------------------------------------------------------------
// Relief experiment
// ----------------------------------------------------------------------

module relief_baseline(part_color) {
    hub75_lab_tube_clamp_baseline(
        hub75_clamp,
        use_tension_bore = use_tension_bore,
        high_resolution = high_resolution,
        part_color = part_color
    );
}

module relief_candidate(part_color) {
    hub75_lab_tube_clamp_candidate(
        hub75_clamp,
        radius = relief_radius,
        bite = relief_bite,
        z_height = relief_z_height,
        z_offset = relief_z_offset,
        use_tension_bore = use_tension_bore,
        high_resolution = high_resolution,
        part_color = part_color
    );
}

module relief_experiment() {
    if (view == "baseline")
        relief_baseline([0.72, 0.72, 0.72, 1]);
    else if (view == "relief")
        relief_candidate([0.88, 0.08, 0.05, 1]);
    else if (view == "removed")
        color([0.92, 0.12, 0.05, 1])
            difference() {
                relief_baseline([1, 1, 1, 1]);
                relief_candidate([1, 1, 1, 1]);
            }
    else {
        translate([-comparison_spacing / 2, 0, 0])
            relief_baseline([0.72, 0.72, 0.72, 1]);

        translate([comparison_spacing / 2, 0, 0])
            relief_candidate([0.88, 0.08, 0.05, 1]);
    }
}

// ----------------------------------------------------------------------
// Tension experiment
//
// lib.scad.clamps v0.1.8 shrinks both inner and outer radii for tension
// geometry, preserving wall_thickness while keeping the nominal ring centre
// fixed.  profile_2d makes that relationship directly inspectable.
// ----------------------------------------------------------------------

module _tension_display() {
    if (tension_display == "profile_2d")
        projection(cut = false)
            children();
    else
        children();
}

module tension_functional(part_color) {
    color(part_color)
        _tension_display()
            tube_clamp_build(
                base_clamp,
                use_tension_bore = false,
                high_resolution = high_resolution
            );
}

module tension_active(part_color) {
    color(part_color)
        _tension_display()
            tube_clamp_build(
                base_clamp,
                use_tension_bore = true,
                high_resolution = high_resolution
            );
}

module tension_experiment() {
    if (tension_view == "functional")
        tension_functional([0.72, 0.72, 0.72, 1]);
    else if (tension_view == "tension")
        tension_active([0.10, 0.45, 0.85, 1]);
    else {
        translate([-tension_comparison_spacing / 2, 0, 0])
            tension_functional([0.72, 0.72, 0.72, 1]);

        translate([tension_comparison_spacing / 2, 0, 0])
            tension_active([0.10, 0.45, 0.85, 1]);
    }
}

// ----------------------------------------------------------------------
// Camera
// ----------------------------------------------------------------------

if (experiment == "relief") {
    $vpt = hub75_lab_development_camera_target();
    $vpr = hub75_lab_development_camera_rotation();
    $vpd =
        view == "comparison"
            ? hub75_lab_development_camera_distance_comparison()
            : hub75_lab_development_camera_distance_single();

    relief_experiment();
} else {
    $vpt = [
        base_clamp.base_thickness
            + tube_clamp_outer_radius(base_clamp),
        0,
        base_clamp.clamp_width / 2
    ];
    $vpr = [0, 0, 0];
    $vpd =
        tension_view == "comparison"
            ? 75
            : 55;

    tension_experiment();
}
