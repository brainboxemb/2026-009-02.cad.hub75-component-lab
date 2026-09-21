// HUB75 component-lab workbench.
//
// The active lock-release experiment uses the actual baseline detachable clamp.
// Only the male lock-release opening profile changes between candidates.

use <lab_orientation.scad>
use <ext/lib.scad.clamps/openscad/tube-clamp/tube_clamp.scad>
use <project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <project_components/tube_mount/tube_mount_interface.scad>
use <lab_components/tube_clamp_relief_candidate.scad>

/* [Lab] */
experiment = "lock_release"; // [relief,tension,lock_release]

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

/* [Male lock release] */
lock_release_view = "single"; // [single,comparison]
lock_release_shape = "trapezoid"; // [rectangular,trapezoid]
lock_release_top_depth = 0.30;
lock_release_comparison_spacing = 28;

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
// Male lock-release experiment
// ----------------------------------------------------------------------

function lock_release_dovetail(shape) =
    hub75_tube_mount_dovetail_create_for_size(
        profile,
        lock_release_shape = shape,
        lock_release_top_depth =
            lock_release_top_depth
    );

function lock_release_clamp(shape) =
    hub75_tube_clamp_create(
        tension_diameter = tension_diameter,
        dovetail = lock_release_dovetail(shape)
    );

module lock_release_clip(
    shape,
    part_color
) {
    hub75_lab_tube_clamp_baseline(
        lock_release_clamp(shape),
        use_tension_bore = false,
        high_resolution = high_resolution,
        part_color = part_color
    );
}

module lock_release_experiment() {
    if (lock_release_view == "comparison") {
        translate([
            -lock_release_comparison_spacing / 2,
            0,
            0
        ])
            lock_release_clip(
                "rectangular",
                [0.72, 0.72, 0.72, 1]
            );

        translate([
            lock_release_comparison_spacing / 2,
            0,
            0
        ])
            lock_release_clip(
                "trapezoid",
                [0.88, 0.08, 0.05, 1]
            );
    } else {
        lock_release_clip(
            lock_release_shape,
            [0.88, 0.08, 0.05, 1]
        );
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
} else if (experiment == "tension") {
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
} else {
    $vpt = hub75_lab_development_camera_target();
    $vpr = hub75_lab_development_camera_rotation();
    $vpd =
        lock_release_view == "comparison"
            ? 145
            : hub75_lab_development_camera_distance_single();

    lock_release_experiment();
}
