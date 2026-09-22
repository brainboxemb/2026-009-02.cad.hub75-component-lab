// File: hub75_tube_clamp.scad
//   Project-owned detachable Ø10 HUB75 tube clamp.
//
// Design: design/design.md
// Design review: hub75_tube_clamp_render.scad
//
// lib.scad.clamps owns the reusable snap-ring geometry and nominal/tension
// bore semantics. HUB75 keeps the ring compact, narrows it to 12 mm and places the
// size-matched vertical male dovetail beside the compact transition. Small,
// medium and large use 2.0 / 2.5 / 3.0 mm dovetail heights. The complete clamp,
// including its male dovetail, stays positioned from the tube-front datum.

use <../../../ext/lib.scad.clamps/openscad/tube-clamp/tube_clamp.scad>
use <../../../ext/lib.scad.forge/openscad/resolution.scad>
use <../../../ext/lib.scad.forge/openscad/transform.scad>
use <../tube_mount_interface.scad>

/* [Component] */
d_profile = "medium"; // [small,medium,large]
c_view = "complete"; // [complete,body]
d_bore = "functional"; // [functional,tension]
d_apply_transition_relief = true;

/* [Transition relief] */
d_relief_radius_mm = 6.0;
d_relief_bite_mm = 0.4;
d_relief_z_height_mm = 4.0;
d_relief_z_offset_mm = 1.0;

/* [Resolution] */
c_resolution = "low"; // [low,high,export]

// ----------------------------------------------------------------------
// Fixed clamp-body baseline
// ----------------------------------------------------------------------

// The clamp body must not change when only the coupler/dovetail profile size
// changes.  The accepted body baseline is the medium-interface connection.
// Small/medium/large therefore share this same compact transition; only the
// actual dovetail and the mating relief required for that dovetail vary.
function _hub75_tube_clamp_reference_dovetail() =
    hub75_tube_mount_dovetail_create_for_size("medium");

function _hub75_tube_clamp_reference_transition_width_mm() =
    hub75_tube_mount_dovetail_mouth_width_mm(
        _hub75_tube_clamp_reference_dovetail()
    );

function _hub75_tube_clamp_reference_transition_depth_mm(
    clamp_width_mm = 12
) =
    let(
        _obj = _hub75_tube_clamp_reference_dovetail(),
        _transition_width_mm =
            _hub75_tube_clamp_reference_transition_width_mm(),
        _lateral_step_mm =
            max(0, (clamp_width_mm - _transition_width_mm) / 2)
    )
    _lateral_step_mm / tan(
        hub75_tube_mount_dovetail_angle_deg(_obj)
    );

function hub75_tube_clamp_create(
    tube_center_y_mm = undef,
    tube_center_z_mm = 10,
    tube_diameter_mm = 10,
    tension_diameter_mm = 9.6,
    wall_thickness_mm = 2.0,
    clamp_width_mm = 12,
    opening_angle_deg = 60,
    transition_width_mm = undef,
    transition_depth_mm = undef,
    dovetail_slide_len_mm = 16,
    dovetail_center_z_mm = undef,
    dovetail_relief_chamfer_depth_mm = undef,
    transition_relief_radius_mm = 6.0,
    transition_relief_bite_mm = 0.4,
    transition_relief_z_height_mm = 4.0,
    transition_relief_z_offset_mm = 1.0,
    extra_mm = 0.01,
    dovetail = hub75_tube_mount_dovetail_create()
) =
    let(
        _active_tube_center_y_mm =
            is_undef(tube_center_y_mm)
                ? hub75_tube_mount_tube_center_y_mm(
                    tube_diameter_mm
                )
                : tube_center_y_mm,
        _active_dovetail_center_z_mm =
            is_undef(dovetail_center_z_mm)
                ? tube_center_z_mm
                : dovetail_center_z_mm,
        _active_transition_width_mm =
            is_undef(transition_width_mm)
                ? _hub75_tube_clamp_reference_transition_width_mm()
                : transition_width_mm,
        _active_transition_depth_mm =
            is_undef(transition_depth_mm)
                ? _hub75_tube_clamp_reference_transition_depth_mm(
                    clamp_width_mm
                )
                : transition_depth_mm,
        _active_relief_chamfer_depth_mm =
            is_undef(dovetail_relief_chamfer_depth_mm)
                ? _active_transition_depth_mm
                : dovetail_relief_chamfer_depth_mm,
        _base_clamp =
            tube_clamp_create(
                tube_diameter = tube_diameter_mm,
                clearance = 0,
                tension_diameter = tension_diameter_mm,
                wall_thickness = wall_thickness_mm,
                clamp_width = clamp_width_mm,
                opening_angle = opening_angle_deg,
                base_thickness = extra_mm,
                transition_width = _active_transition_width_mm,
                transition_depth = _active_transition_depth_mm,
                extra = extra_mm
            )
    )
    assert(dovetail_slide_len_mm > 0,
        "tube-clamp dovetail_slide_len_mm must be > 0")
    assert(_active_transition_width_mm > 0,
        "tube-clamp transition_width_mm must be > 0")
    assert(_active_transition_width_mm <= clamp_width_mm,
        "tube-clamp transition_width_mm must not exceed clamp_width_mm")
    assert(_active_transition_depth_mm > 0,
        "tube-clamp transition_depth_mm must be > 0")
    assert(_active_relief_chamfer_depth_mm >= 0,
        "tube-clamp dovetail_relief_chamfer_depth_mm must be >= 0")
    assert(_active_relief_chamfer_depth_mm <= _active_transition_depth_mm,
        "tube-clamp dovetail relief must not exceed transition depth")
    assert(transition_relief_radius_mm > 0,
        "tube-clamp transition_relief_radius_mm must be > 0")
    assert(
        transition_relief_bite_mm >= 0
            && transition_relief_bite_mm <= transition_relief_radius_mm,
        "tube-clamp transition relief bite must be within the relief radius"
    )
    assert(
        transition_relief_z_height_mm > 0,
        "tube-clamp transition_relief_z_height_mm must be > 0"
    )
    object(
        tube_center_y_mm = _active_tube_center_y_mm,
        tube_center_z_mm = tube_center_z_mm,
        dovetail = dovetail,
        dovetail_slide_len_mm = dovetail_slide_len_mm,
        dovetail_center_z_mm = _active_dovetail_center_z_mm,
        dovetail_relief_chamfer_depth_mm =
            _active_relief_chamfer_depth_mm,
        transition_relief_radius_mm = transition_relief_radius_mm,
        transition_relief_bite_mm = transition_relief_bite_mm,
        transition_relief_z_height_mm =
            transition_relief_z_height_mm,
        transition_relief_z_offset_mm =
            transition_relief_z_offset_mm,
        base_clamp = _base_clamp
    );

function hub75_tube_clamp_create_for_host_depth(host_depth_mm) =
    hub75_tube_clamp_create(
        dovetail =
            hub75_tube_mount_dovetail_create(
                host_depth_mm = host_depth_mm
            )
    );

function hub75_tube_clamp_create_for_size(size) =
    hub75_tube_clamp_create(
        dovetail = hub75_tube_mount_dovetail_create_for_size(size)
    );

function hub75_tube_clamp_tube_center_y_mm(obj) =
    obj.tube_center_y_mm;

function hub75_tube_clamp_tube_center_z_mm(obj) =
    obj.tube_center_z_mm;

function hub75_tube_clamp_functional_diameter_mm(obj) =
    tube_clamp_functional_diameter(obj.base_clamp);

function hub75_tube_clamp_tension_diameter_mm(obj) =
    tube_clamp_tension_diameter(obj.base_clamp);

function hub75_tube_clamp_outer_diameter_mm(obj) =
    2 * tube_clamp_outer_radius(obj.base_clamp);

function hub75_tube_clamp_dovetail_relief_chamfer_depth_mm(obj) =
    obj.dovetail_relief_chamfer_depth_mm;


// ----------------------------------------------------------------------
// Public geometry
// ----------------------------------------------------------------------

module hub75_tube_clamp_body_build(
    obj,
    part_color = [0.88, 0.08, 0.05, 1],
    use_tension_bore = true,
    resolution = FG_RES_HIGH(),
    apply_transition_relief = true
) {
    fg_res_apply(resolution)
        color(part_color)
        _hub75_tube_clamp_ring_build(
            obj,
            use_tension_bore,
            resolution,
            apply_transition_relief
        );
}

module hub75_tube_clamp_build(
    obj,
    part_color = [0.88, 0.08, 0.05, 1],
    use_tension_bore = true,
    resolution = FG_RES_HIGH(),
    apply_transition_relief = true
) {
    fg_res_apply(resolution)
        color(part_color)
        union() {
            difference() {
                _hub75_tube_clamp_ring_build(
                    obj,
                    use_tension_bore,
                    resolution,
                    apply_transition_relief
                );

                _hub75_tube_clamp_dovetail_relief_cutter(obj);
                _hub75_tube_clamp_dovetail_relief_chamfer_cutter(obj);
            }

            _hub75_tube_clamp_dovetail_build(obj);
        }
}


// ----------------------------------------------------------------------
// Private implementation
// ----------------------------------------------------------------------

module _hub75_tube_clamp_ring_build(
    obj,
    use_tension_bore,
    resolution,
    apply_transition_relief = true
) {
    _local_center_x_mm =
        obj.base_clamp.base_thickness
        + tube_clamp_outer_radius(obj.base_clamp);
    _y_translation_mm =
        obj.tube_center_y_mm + _local_center_x_mm;

    // lib.scad.clamps design Z (obj extrusion) becomes project X (tube axis).
    // Clamp design X becomes -project Y, keeping the ring tangent near Y=0.
    // Clamp design Y becomes -project Z around the tube centre.
    fg_xf_frame(
        pos_mm = [
            -obj.base_clamp.clamp_width / 2,
            _y_translation_mm,
            obj.tube_center_z_mm
        ],
        x_axis = [0, -1, 0],
        y_axis = [0, 0, -1]
    )
        difference() {
            tube_clamp_build(
                obj.base_clamp,
                use_tension_bore = use_tension_bore,
                high_resolution = resolution != FG_RES_LOW()
            );

            if (
                apply_transition_relief
                && obj.transition_relief_bite_mm > 0
            )
                _hub75_tube_clamp_transition_relief_cutter_local(
                    obj,
                    resolution
                );
        }
}


// Small round side relief accepted in the component lab.
//
// The relief is defined in the component lab orientation:
//   project X -> lab X
//   project Y -> lab -Z
//   project Z -> lab Y
//
// Relative to the reusable clamp design orientation this means:
//   lab X = clamp design Z - clamp_width/2
//   lab Y = -clamp design Y + tube_center_z
//   lab Z = clamp design X - project Y translation
//
// The accepted low lab-Z cylinders therefore become short cylinders along clamp design X
// whose circular centres sit just outside the two clamp design Z side
// faces.  This preserves the lab result exactly without making the relief
// dependent on the selected dovetail profile height.
module _hub75_tube_clamp_transition_relief_cutter_local(
    obj,
    resolution
) {
    _base_obj = obj.base_clamp;
    radius = obj.transition_relief_radius_mm;
    bite = obj.transition_relief_bite_mm;
    z_height = obj.transition_relief_z_height_mm;
    z_offset = obj.transition_relief_z_offset_mm;

    outer_r = tube_clamp_outer_radius(_base_obj);
    ring_center_x =
        _base_obj.base_thickness
        + outer_r;
    attach_x = min(
        _base_obj.base_thickness
            + _base_obj.transition_depth,
        ring_center_x
            + outer_r
            - _base_obj.extra
    );

    // Lab-Z position translated back to clamp design X.
    cutter_x =
        attach_x
        + z_offset;

    // A radius-R cylinder centred R-bite outside either side face enters the
    // 12 mm obj by exactly 'bite'.
    side_center_offset =
        radius
        - bite;

    for (side = [-1, 1]) {
        cutter_z =
            side < 0
                ? -side_center_offset
                : _base_obj.clamp_width
                    + side_center_offset;

        fg_xf_move([
            cutter_x - z_height / 2,
            0,
            cutter_z
        ])
            fg_xf_yrot(90)
                cylinder(
                    r = radius,
                    h = z_height
                );
    }
}


module _hub75_tube_clamp_dovetail_relief_cutter(obj) {
    hub75_tube_mount_dovetail_male_relief_cutter(
        obj.dovetail,
        slide_len_mm = obj.dovetail_slide_len_mm,
        relief_width_mm = obj.base_clamp.clamp_width,
        center_x_mm = 0,
        center_z_mm = obj.dovetail_center_z_mm
    );
}

module _hub75_tube_clamp_dovetail_relief_chamfer_cutter(obj) {
    chamfer_depth =
        hub75_tube_clamp_dovetail_relief_chamfer_depth_mm(obj);

    if (chamfer_depth > 0) {
        mouth_y =
            hub75_tube_mount_dovetail_mouth_y_mm();
        mouth_half_width =
            hub75_tube_mount_dovetail_mouth_width_mm(
                obj.dovetail
            ) / 2;
        clamp_half_width =
            obj.base_clamp.clamp_width / 2;
        z_min =
            obj.dovetail_center_z_mm
            - obj.dovetail_slide_len_mm / 2
            - obj.base_clamp.extra;
        z_length =
            obj.dovetail_slide_len_mm
            + 2 * obj.base_clamp.extra;

        // Project-local finishing cut. The generic mechint relief owns the
        // exact dovetail contour; this wedge only softens the abrupt obj-body
        // shoulder immediately in front of the male mouth. Its slope follows
        // the same angle as the dovetail flank.
        translate([0, 0, z_min])
            linear_extrude(height = z_length)
                union() {
                    polygon(points = [
                        [
                            mouth_half_width
                                - obj.base_clamp.extra,
                            mouth_y + obj.base_clamp.extra
                        ],
                        [
                            clamp_half_width
                                + obj.base_clamp.extra,
                            mouth_y + obj.base_clamp.extra
                        ],
                        [
                            clamp_half_width
                                + obj.base_clamp.extra,
                            mouth_y
                                - chamfer_depth
                                - obj.base_clamp.extra
                        ]
                    ]);

                    mirror([1, 0, 0])
                        polygon(points = [
                            [
                                mouth_half_width
                                    - obj.base_clamp.extra,
                                mouth_y + obj.base_clamp.extra
                            ],
                            [
                                clamp_half_width
                                    + obj.base_clamp.extra,
                                mouth_y + obj.base_clamp.extra
                            ],
                            [
                                clamp_half_width
                                    + obj.base_clamp.extra,
                                mouth_y
                                    - chamfer_depth
                                    - obj.base_clamp.extra
                            ]
                        ]);
                }
    }
}

module _hub75_tube_clamp_dovetail_build(obj) {
    hub75_tube_mount_dovetail_male_build(
        obj.dovetail,
        slide_len_mm = obj.dovetail_slide_len_mm,
        center_x_mm = 0,
        center_z_mm = obj.dovetail_center_z_mm
    );
}

// ----------------------------------------------------------------------
// Standalone component entrypoint
// ----------------------------------------------------------------------
//
// Top-level code is intentionally kept here so this component can be opened
// directly in OpenSCAD. Consumers normally import the API with use<...>, which
// does not execute this standalone entrypoint.

_standalone_clamp =
    hub75_tube_clamp_create(
        dovetail =
            hub75_tube_mount_dovetail_create_for_size(
                d_profile
            ),
        transition_relief_radius_mm =
            d_relief_radius_mm,
        transition_relief_bite_mm =
            d_relief_bite_mm,
        transition_relief_z_height_mm =
            d_relief_z_height_mm,
        transition_relief_z_offset_mm =
            d_relief_z_offset_mm
    );

_standalone_use_tension =
    d_bore == "tension";

if (c_view == "body")
    hub75_tube_clamp_body_build(
        _standalone_clamp,
        use_tension_bore =
            _standalone_use_tension,
        resolution =
            c_resolution,
        apply_transition_relief =
            d_apply_transition_relief
    );
else
    hub75_tube_clamp_build(
        _standalone_clamp,
        use_tension_bore =
            _standalone_use_tension,
        resolution =
            c_resolution,
        apply_transition_relief =
            d_apply_transition_relief
    );
