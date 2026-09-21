// File: hub75_tube_clamp.scad
//   Project-owned detachable Ø10 HUB75 tube clamp.
//
// Design: design/design.md
// Design review: hub75_tube_clamp_render.scad
//
// lib.scad.clamps owns the reusable snap-ring geometry and nominal/tension bore
// semantics. HUB75 keeps the ring compact, narrows it to 12 mm and places the
// size-matched vertical male dovetail beside the compact transition. Small,
// medium and large use 2.0 / 2.5 / 3.0 mm dovetail heights. The complete clamp,
// including its male dovetail, stays positioned from the tube-front datum.

use <../../../ext/lib.scad.clamps/openscad/tube-clamp/tube_clamp.scad>
use <../tube_mount_interface.scad>

/* [Profile] */
preview_profile = "medium"; // [small,medium,large]

/* [Preview] */
preview_view = "complete"; // [complete,body]
preview_bore = "functional"; // [functional,tension]
preview_transition_relief = true;

/* [Transition relief] */
preview_relief_radius = 10.0;
preview_relief_bite = 1.0;
preview_relief_face_depth = 2.0;

/* [Resolution] */
preview_high_resolution = false;


// ----------------------------------------------------------------------
// Fixed clamp-body baseline
// ----------------------------------------------------------------------

// The clamp body must not change when only the coupler/dovetail profile size
// changes.  The accepted body baseline is the medium-interface connection.
// Small/medium/large therefore share this same compact transition; only the
// actual dovetail and the mating relief required for that dovetail vary.
function _hub75_tube_clamp_reference_dovetail() =
    hub75_tube_mount_dovetail_create_for_size("medium");

function _hub75_tube_clamp_reference_transition_width() =
    hub75_tube_mount_dovetail_mouth_width(
        _hub75_tube_clamp_reference_dovetail()
    );

function _hub75_tube_clamp_reference_transition_depth(
    clamp_width = 12
) =
    let(
        ref = _hub75_tube_clamp_reference_dovetail(),
        transition_width =
            _hub75_tube_clamp_reference_transition_width(),
        lateral_step =
            max(0, (clamp_width - transition_width) / 2)
    )
    lateral_step / tan(
        hub75_tube_mount_dovetail_angle(ref)
    );

function hub75_tube_clamp_create(
    tube_center_y = undef,
    tube_center_z = 10,
    tube_diameter = 10,
    tension_diameter = 9.6,
    wall_thickness = 2.0,
    clamp_width = 12,
    opening_angle = 60,
    transition_width = undef,
    transition_depth = undef,
    dovetail_slide = 16,
    dovetail_center_z = undef,
    dovetail_relief_chamfer_depth = undef,
    transition_relief_radius = 10.0,
    transition_relief_bite = 1.0,
    transition_relief_face_depth = 2.0,
    extra = 0.01,
    dovetail = hub75_tube_mount_dovetail_create()
) =
    let(
        active_tube_center_y =
            is_undef(tube_center_y)
                ? hub75_tube_mount_tube_center_y(
                    tube_diameter
                )
                : tube_center_y,
        active_dovetail_center_z =
            is_undef(dovetail_center_z)
                ? tube_center_z
                : dovetail_center_z,
        active_transition_width =
            is_undef(transition_width)
                ? _hub75_tube_clamp_reference_transition_width()
                : transition_width,
        active_transition_depth =
            is_undef(transition_depth)
                ? _hub75_tube_clamp_reference_transition_depth(
                    clamp_width
                )
                : transition_depth,
        active_relief_chamfer_depth =
            is_undef(dovetail_relief_chamfer_depth)
                ? active_transition_depth
                : dovetail_relief_chamfer_depth,
        base_clamp =
            tube_clamp_create(
                tube_diameter = tube_diameter,
                clearance = 0,
                tension_diameter = tension_diameter,
                wall_thickness = wall_thickness,
                clamp_width = clamp_width,
                opening_angle = opening_angle,
                base_thickness = extra,
                transition_width = active_transition_width,
                transition_depth = active_transition_depth,
                extra = extra
            )
    )
    assert(dovetail_slide > 0,
        "tube-clamp dovetail_slide must be > 0")
    assert(active_transition_width > 0,
        "tube-clamp transition_width must be > 0")
    assert(active_transition_width <= clamp_width,
        "tube-clamp transition_width must not exceed clamp_width")
    assert(active_transition_depth > 0,
        "tube-clamp transition_depth must be > 0")
    assert(active_relief_chamfer_depth >= 0,
        "tube-clamp dovetail_relief_chamfer_depth must be >= 0")
    assert(active_relief_chamfer_depth <= active_transition_depth,
        "tube-clamp dovetail_relief_chamfer_depth must not exceed transition_depth")
    assert(transition_relief_radius > 0,
        "tube-clamp transition_relief_radius must be > 0")
    assert(
        transition_relief_bite >= 0
            && transition_relief_bite <= transition_relief_radius,
        "tube-clamp transition_relief_bite must be between 0 and transition_relief_radius"
    )
    assert(
        transition_relief_face_depth > 0
            && transition_relief_face_depth
                <= clamp_width / 2,
        "tube-clamp transition_relief_face_depth must be > 0 and <= half clamp_width"
    )
    object(
        tube_center_y = active_tube_center_y,
        tube_center_z = tube_center_z,
        dovetail = dovetail,
        dovetail_slide = dovetail_slide,
        dovetail_center_z = active_dovetail_center_z,
        dovetail_relief_chamfer_depth =
            active_relief_chamfer_depth,
        transition_relief_radius = transition_relief_radius,
        transition_relief_bite = transition_relief_bite,
        transition_relief_face_depth =
            transition_relief_face_depth,
        base_clamp = base_clamp
    );

function hub75_tube_clamp_create_for_host_depth(host_depth) =
    hub75_tube_clamp_create(
        dovetail =
            hub75_tube_mount_dovetail_create(
                host_depth = host_depth
            )
    );

function hub75_tube_clamp_create_for_size(size) =
    hub75_tube_clamp_create(
        dovetail = hub75_tube_mount_dovetail_create_for_size(size)
    );

function hub75_tube_clamp_tube_center_y(clamp) =
    clamp.tube_center_y;

function hub75_tube_clamp_tube_center_z(clamp) =
    clamp.tube_center_z;

function hub75_tube_clamp_functional_diameter(clamp) =
    tube_clamp_functional_diameter(clamp.base_clamp);

function hub75_tube_clamp_tension_diameter(clamp) =
    tube_clamp_tension_diameter(clamp.base_clamp);

function hub75_tube_clamp_outer_diameter(clamp) =
    2 * tube_clamp_outer_radius(clamp.base_clamp);

function hub75_tube_clamp_dovetail_relief_chamfer_depth(clamp) =
    clamp.dovetail_relief_chamfer_depth;


// ----------------------------------------------------------------------
// Public geometry
// ----------------------------------------------------------------------

module hub75_tube_clamp_body_build(
    clamp,
    part_color = [0.88, 0.08, 0.05, 1],
    use_tension_bore = true,
    high_resolution = true,
    apply_transition_relief = true
) {
    color(part_color)
        _hub75_tube_clamp_ring_build(
            clamp,
            use_tension_bore,
            high_resolution,
            apply_transition_relief
        );
}

module hub75_tube_clamp_build(
    clamp,
    part_color = [0.88, 0.08, 0.05, 1],
    use_tension_bore = true,
    high_resolution = true,
    apply_transition_relief = true
) {
    color(part_color)
        union() {
            difference() {
                _hub75_tube_clamp_ring_build(
                    clamp,
                    use_tension_bore,
                    high_resolution,
                    apply_transition_relief
                );

                _hub75_tube_clamp_dovetail_relief_cutter(clamp);
                _hub75_tube_clamp_dovetail_relief_chamfer_cutter(clamp);
            }

            _hub75_tube_clamp_dovetail_build(clamp);
        }
}


// ----------------------------------------------------------------------
// Private implementation
// ----------------------------------------------------------------------

module _hub75_tube_clamp_ring_build(
    clamp,
    use_tension_bore,
    high_resolution,
    apply_transition_relief = true
) {
    local_center_x =
        clamp.base_clamp.base_thickness
        + tube_clamp_outer_radius(clamp.base_clamp);
    y_translation =
        clamp.tube_center_y + local_center_x;

    // Library local Z (clamp extrusion) becomes project X (tube axis).
    // Library local X becomes -project Y, keeping the ring tangent near Y=0.
    // Library local Y becomes -project Z around the tube centre.
    multmatrix([
        [ 0,  0,  1, -clamp.base_clamp.clamp_width / 2],
        [-1,  0,  0,  y_translation],
        [ 0, -1,  0,  clamp.tube_center_z],
        [ 0,  0,  0,  1]
    ])
        difference() {
            tube_clamp_build(
                clamp.base_clamp,
                use_tension_bore = use_tension_bore,
                high_resolution = high_resolution
            );

            if (
                apply_transition_relief
                && clamp.transition_relief_bite > 0
            )
                _hub75_tube_clamp_transition_relief_cutter_local(
                    clamp,
                    high_resolution
                );
        }
}


// Shallow round bite at the LOWER transition foot: the sharp corner where the
// compact sloped transition leaves the flat base / dovetail connection.
//
// This deliberately does NOT target the upper transition-to-ring attach point.
// In the reusable clamp's native profile the target vertex is
// [base_thickness, +/- transition_width/2].
//
// The cylinders use native Z as their axis. Native Z maps to project X, which is
// printer Z in the intended side-print orientation. They are intentionally
// short and applied from both clamp faces, matching the requested small round
// bite on this side and on the back rather than cutting a full-width tunnel.
module _hub75_tube_clamp_transition_relief_cutter_local(
    clamp,
    high_resolution
) {
    b = clamp.base_clamp;
    radius = clamp.transition_relief_radius;
    bite = clamp.transition_relief_bite;
    face_depth = clamp.transition_relief_face_depth;

    foot_x = b.base_thickness;
    foot_y = b.transition_width / 2;
    cutter_y =
        foot_y
        + radius
        - bite;

    // Two profile sides (+/-Y) x two physical clamp faces (native Z).
    for (profile_side = [-1, 1])
        for (face = [0, 1])
            translate([
                foot_x,
                profile_side * cutter_y,
                face == 0
                    ? -b.extra
                    : b.clamp_width - face_depth,
            ])
                cylinder(
                    r = radius,
                    h = face_depth + b.extra,
                    $fn =
                        high_resolution
                            ? 96
                            : 32
                );
}


module _hub75_tube_clamp_dovetail_relief_cutter(clamp) {
    hub75_tube_mount_dovetail_male_relief_cutter(
        dovetail = clamp.dovetail,
        slide = clamp.dovetail_slide,
        relief_width = clamp.base_clamp.clamp_width,
        center_x = 0,
        center_z = clamp.dovetail_center_z
    );
}

module _hub75_tube_clamp_dovetail_relief_chamfer_cutter(clamp) {
    chamfer_depth =
        hub75_tube_clamp_dovetail_relief_chamfer_depth(clamp);

    if (chamfer_depth > 0) {
        mouth_y =
            hub75_tube_mount_dovetail_mouth_y();
        mouth_half_width =
            hub75_tube_mount_dovetail_mouth_width(
                clamp.dovetail
            ) / 2;
        clamp_half_width =
            clamp.base_clamp.clamp_width / 2;
        z_min =
            clamp.dovetail_center_z
            - clamp.dovetail_slide / 2
            - clamp.base_clamp.extra;
        z_length =
            clamp.dovetail_slide
            + 2 * clamp.base_clamp.extra;

        // Project-local finishing cut. The generic mechint relief owns the
        // exact dovetail contour; this wedge only softens the abrupt clamp-body
        // shoulder immediately in front of the male mouth. Its slope follows
        // the same angle as the dovetail flank.
        translate([0, 0, z_min])
            linear_extrude(height = z_length)
                union() {
                    polygon(points = [
                        [
                            mouth_half_width
                                - clamp.base_clamp.extra,
                            mouth_y + clamp.base_clamp.extra
                        ],
                        [
                            clamp_half_width
                                + clamp.base_clamp.extra,
                            mouth_y + clamp.base_clamp.extra
                        ],
                        [
                            clamp_half_width
                                + clamp.base_clamp.extra,
                            mouth_y
                                - chamfer_depth
                                - clamp.base_clamp.extra
                        ]
                    ]);

                    mirror([1, 0, 0])
                        polygon(points = [
                            [
                                mouth_half_width
                                    - clamp.base_clamp.extra,
                                mouth_y + clamp.base_clamp.extra
                            ],
                            [
                                clamp_half_width
                                    + clamp.base_clamp.extra,
                                mouth_y + clamp.base_clamp.extra
                            ],
                            [
                                clamp_half_width
                                    + clamp.base_clamp.extra,
                                mouth_y
                                    - chamfer_depth
                                    - clamp.base_clamp.extra
                            ]
                        ]);
                }
    }
}

module _hub75_tube_clamp_dovetail_build(clamp) {
    hub75_tube_mount_dovetail_male_build(
        dovetail = clamp.dovetail,
        slide = clamp.dovetail_slide,
        center_x = 0,
        center_z = clamp.dovetail_center_z
    );
}


// ----------------------------------------------------------------------
// Standalone Customizer preview
// ----------------------------------------------------------------------

_preview_clamp =
    hub75_tube_clamp_create(
        dovetail =
            hub75_tube_mount_dovetail_create_for_size(
                preview_profile
            ),
        transition_relief_radius =
            preview_relief_radius,
        transition_relief_bite =
            preview_relief_bite,
        transition_relief_face_depth =
            preview_relief_face_depth
    );

_preview_use_tension_bore =
    preview_bore == "tension";

if (preview_view == "body")
    hub75_tube_clamp_body_build(
        _preview_clamp,
        use_tension_bore = _preview_use_tension_bore,
        high_resolution = preview_high_resolution,
        apply_transition_relief = preview_transition_relief
    );
else
    hub75_tube_clamp_build(
        _preview_clamp,
        use_tension_bore = _preview_use_tension_bore,
        high_resolution = preview_high_resolution,
        apply_transition_relief = preview_transition_relief
    );
