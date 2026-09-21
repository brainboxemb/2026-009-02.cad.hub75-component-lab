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
c_experiment = "lock_release"; // [relief,tension,lock_release]

/* [Display] */
c_orientation = "design"; // [design,project,print]
c_view = "iso"; // [iso,front,side,top]

/* [Profile] */
d_profile = "medium"; // [small,medium,large]

/* [Relief view] */
c_relief_view = "comparison"; // [relief,baseline,comparison,removed]
d_bore = "functional"; // [functional,tension]

/* [Transition relief] */
d_relief_radius_mm = 6.0;
d_relief_bite_mm = 0.4;
d_relief_z_height_mm = 4.0;
d_relief_z_offset_mm = 1.0;

/* [Tension experiment] */
c_tension_view = "comparison"; // [functional,tension,comparison]
c_tension_display = "profile_2d"; // [profile_2d,model_3d]
d_tension_diameter_mm = 9.6;
c_tension_comparison_spacing_mm = 18;

/* [Male lock release] */
c_lock_release_mode = "single"; // [single,comparison]
d_lock_release_shape = "trapezoid"; // [rectangular,trapezoid]
d_lock_release_taper_angle_deg = 45;
c_lock_release_comparison_spacing_mm = 28;

/* [Preview] */
c_high_resolution = false;
c_comparison_spacing_mm = 18;

_hub75_clamp =
    hub75_tube_clamp_create(
        tension_diameter = d_tension_diameter_mm,
        dovetail =
            hub75_tube_mount_dovetail_create_for_size(
                d_profile
            )
    );

_base_clamp = _hub75_clamp.base_clamp;
_use_tension_bore = d_bore == "tension";

// ----------------------------------------------------------------------
// Relief experiment
// ----------------------------------------------------------------------

module _relief_baseline(part_color) {
    hub75_lab_tube_clamp_baseline(
        _hub75_clamp,
        use_tension_bore = _use_tension_bore,
        high_resolution = c_high_resolution,
        part_color = part_color,
        orientation = "design"
    );
}

module _relief_candidate(part_color) {
    hub75_lab_tube_clamp_candidate(
        _hub75_clamp,
        radius = d_relief_radius_mm,
        bite = d_relief_bite_mm,
        z_height = d_relief_z_height_mm,
        z_offset = d_relief_z_offset_mm,
        use_tension_bore = _use_tension_bore,
        high_resolution = c_high_resolution,
        part_color = part_color
    );
}

module _relief_experiment() {
    if (c_relief_view == "baseline")
        _relief_baseline([0.72, 0.72, 0.72, 1]);
    else if (c_relief_view == "relief")
        _relief_candidate([0.88, 0.08, 0.05, 1]);
    else if (c_relief_view == "removed")
        color([0.92, 0.12, 0.05, 1])
            difference() {
                _relief_baseline([1, 1, 1, 1]);
                _relief_candidate([1, 1, 1, 1]);
            }
    else {
        translate([
            -c_comparison_spacing_mm / 2,
            0,
            0
        ])
            _relief_baseline(
                [0.72, 0.72, 0.72, 1]
            );

        translate([
            c_comparison_spacing_mm / 2,
            0,
            0
        ])
            _relief_candidate(
                [0.88, 0.08, 0.05, 1]
            );
    }
}

// ----------------------------------------------------------------------
// Tension experiment
// ----------------------------------------------------------------------

module _tension_display() {
    if (c_tension_display == "profile_2d")
        projection(cut = false)
            children();
    else
        children();
}

module _tension_functional(part_color) {
    color(part_color)
        _tension_display()
            tube_clamp_build(
                _base_clamp,
                use_tension_bore = false,
                high_resolution = c_high_resolution
            );
}

module _tension_active(part_color) {
    color(part_color)
        _tension_display()
            tube_clamp_build(
                _base_clamp,
                use_tension_bore = true,
                high_resolution = c_high_resolution
            );
}

module _tension_experiment() {
    if (c_tension_view == "functional")
        _tension_functional(
            [0.72, 0.72, 0.72, 1]
        );
    else if (c_tension_view == "tension")
        _tension_active(
            [0.10, 0.45, 0.85, 1]
        );
    else {
        translate([
            -c_tension_comparison_spacing_mm / 2,
            0,
            0
        ])
            _tension_functional(
                [0.72, 0.72, 0.72, 1]
            );

        translate([
            c_tension_comparison_spacing_mm / 2,
            0,
            0
        ])
            _tension_active(
                [0.10, 0.45, 0.85, 1]
            );
    }
}

// ----------------------------------------------------------------------
// Male lock-release experiment
// ----------------------------------------------------------------------

function _lock_release_dovetail(shape) =
    hub75_tube_mount_dovetail_create_for_size(
        d_profile,
        lock_release_shape = shape,
        lock_release_taper_angle_deg =
            d_lock_release_taper_angle_deg
    );

function _lock_release_clamp(shape) =
    hub75_tube_clamp_create(
        tension_diameter = d_tension_diameter_mm,
        dovetail = _lock_release_dovetail(shape)
    );

module _lock_release_clip(
    shape,
    part_color
) {
    hub75_lab_tube_clamp_baseline(
        _lock_release_clamp(shape),
        use_tension_bore = false,
        high_resolution = c_high_resolution,
        part_color = part_color,
        orientation = c_orientation
    );
}

module _lock_release_experiment() {
    if (c_lock_release_mode == "comparison") {
        translate([
            -c_lock_release_comparison_spacing_mm / 2,
            0,
            0
        ])
            _lock_release_clip(
                "rectangular",
                [0.72, 0.72, 0.72, 1]
            );

        translate([
            c_lock_release_comparison_spacing_mm / 2,
            0,
            0
        ])
            _lock_release_clip(
                "trapezoid",
                [0.88, 0.08, 0.05, 1]
            );
    } else {
        _lock_release_clip(
            d_lock_release_shape,
            [0.88, 0.08, 0.05, 1]
        );
    }
}

// ----------------------------------------------------------------------
// Camera
// ----------------------------------------------------------------------

$vpt = hub75_lab_camera_target(c_orientation);
$vpr = hub75_lab_camera_rotation(c_view);

$vpd =
    c_experiment == "lock_release"
        && c_lock_release_mode == "comparison"
            ? hub75_lab_camera_distance_comparison(
                c_orientation
            )
            : c_experiment == "relief"
                && c_relief_view == "comparison"
                    ? hub75_lab_camera_distance_comparison(
                        "design"
                    )
                    : hub75_lab_camera_distance_single(
                        c_orientation
                    );

if (c_experiment == "relief")
    _relief_experiment();
else if (c_experiment == "tension")
    _tension_experiment();
else
    _lock_release_experiment();
