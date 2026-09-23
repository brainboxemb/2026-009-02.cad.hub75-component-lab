// File: hub75_corner_edge_coupler.scad
//   Project-specific top-corner coupler for one portrait HUB75 panel.
//
// - Design: design/design.md
// - Design review: hub75_corner_edge_coupler_render.scad
//
// Printable variants:
// - side="left"  : top-left, rotated 180 degrees also fits bottom-right;
// - side="right" : top-right, rotated 180 degrees also fits bottom-left.
//
// Coordinate system:
// - local X=0 / Z=0 is the nominal 160 x 320 mm panel corner;
// - local Y=0 is the HUB75 rear mounting plane;
// - the base extends toward +Y, behind the display;
// - fitted guides and reinforcement locators extend toward -Y.
//
// This first corner implementation deliberately has NO aluminium-tube clip.
// It establishes the corner body and panel fit before reinforcement hardware.

use <../../../ext/lib.scad.forge/openscad/resolution.scad>
use <../../../ext/lib.scad.forge/openscad/transform.scad>
use <../../../ext/lib.scad.forge/openscad/cutter.scad>
use <../../../ext/lib.scad.forge/openscad/csg.scad>
use <../../../ext/lib.scad.hub75/openscad/p5-64x32-panel/hub75_p5_64x32_panel.scad>
use <../hub75_panel_mating.scad>

/* [Variant] */
d_side = "left"; // [left,right]

/* [Core profile] */
d_profile_size_mm = 80;
d_outside_projection_mm = 19.5;
d_wall_thickness_mm = 4;
d_fit_clearance_mm = 0.25;
d_base_thickness_mm = 3;
d_guide_height_mm = 6;
d_inside_corner_radius_mm = 10;
d_outside_corner_radius_mm = 6;
d_guide_end_rounding_mm = 1.5;

/* [Mounting] */
d_screw_hole_diameter_mm = 3.4;
d_screw_relief_depth_mm = 0.20;
d_screw_relief_radial_mm = 0.40;
d_mounting_tube_radial_clearance_mm = 0.45;
d_mounting_tube_axial_clearance_mm = 0.40;
d_locator_pin_clearance_mm = 0.35;

d_reinforcement_bushing_clearance_mm = 0.45;
d_reinforcement_locator_pad_radial_clearance_mm = 0.30;
d_reinforcement_locator_pad_axial_clearance_mm = 0.10;
d_reinforcement_locator_pin_radial_clearance_mm = 0.20;
d_reinforcement_locator_pin_length_mm = 2.0;

/* [Surface reference details] */
d_show_reference_pockets = true;
d_reference_pocket_diameter_mm = 3.0;
d_reference_pocket_depth_mm = 2.0;
d_reference_pocket_min_back_wall_mm = 0.7;
d_reference_pocket_end_diameter_mm = 2.0;
d_reference_pocket_taper_depth_mm = 0.5;
d_reference_pocket_pitch_mm = 10.0;
d_reference_pocket_steps = [2, 3, 4];
d_reference_pocket_lane_grid_mm = 2.5;
d_reference_pocket_lane_fraction = 0.25;
d_reference_pocket_edge_margin_mm = 4.0;

d_show_center_reference_marks = true;
d_center_mark_depth_mm = 0.40;
d_center_mark_pitch_mm = 10.0;
d_center_mark_major_length_mm = 4.0;
d_center_mark_minor_length_mm = 2.2;
d_center_mark_width_mm = 0.8;
d_center_mark_cross_length_mm = 6.0;
d_center_mark_screw_keepout_mm = 3.0;

/* [Preview] */
c_view = "final"; // [final,functional,profile,base,screw-hole,tube-pocket,locator-pin-clearance,guides,reinforcement-locator,reference-pockets,center-marks]

/* [Resolution] */
c_resolution = "high"; // [low,high,export]

_standalone_render_fn =
    c_resolution == FG_RES_LOW()
        ? 48
        : 192;

_HUB75_CORNER_EDGE_COUPLER_EPS = 0.05;


// ----------------------------------------------------------------------
// Public object API
// ----------------------------------------------------------------------

function hub75_corner_edge_coupler_create(
    side = "left",
    panel_obj = hub75_p5_64x32_panel_create(),
    profile_size = 80,
    outside_projection = 19.5,
    wall_thickness = 4,
    fit_clearance = 0.25,
    base_thickness = 3,
    guide_height = 6,
    inside_corner_radius = 10,
    outside_corner_radius = 6,
    guide_end_rounding = 1.5,
    render_fn = 192,

    screw_hole_diameter = 3.4,
    screw_relief_depth = 0.20,
    screw_relief_radial = 0.40,
    mounting_tube_radial_clearance = 0.45,
    mounting_tube_axial_clearance = 0.40,
    locator_pin_clearance = 0.35,

    reinforcement_bushing_clearance = 0.45,
    reinforcement_locator_pad_radial_clearance = 0.30,
    reinforcement_locator_pad_axial_clearance = 0.10,
    reinforcement_locator_pin_radial_clearance = 0.20,
    reinforcement_locator_pin_length = 2.0,

    show_reference_pockets = true,
    reference_pocket_diameter = 3.0,
    reference_pocket_depth = 2.0,
    reference_pocket_min_back_wall = 0.7,
    reference_pocket_end_diameter = 2.0,
    reference_pocket_taper_depth = 0.5,
    reference_pocket_pitch = 10.0,
    reference_pocket_steps = [2, 3, 4],
    reference_pocket_lane_grid = 2.5,
    reference_pocket_lane_fraction = 0.25,
    reference_pocket_edge_margin = 4.0,

    show_center_reference_marks = true,
    center_mark_depth = 0.40,
    center_mark_pitch = 10.0,
    center_mark_major_length = 4.0,
    center_mark_minor_length = 2.2,
    center_mark_width = 0.8,
    center_mark_cross_length = 6.0,
    center_mark_screw_keepout = 3.0
) =
    let(
        x_inward = side == "left" ? 1 : -1,
        nominal_half_x =
            hub75_p5_64x32_panel_nominal_width(panel_obj) / 2,
        nominal_half_z =
            hub75_p5_64x32_panel_nominal_height(panel_obj) / 2,
        physical_half_x =
            hub75_p5_64x32_panel_width(panel_obj) / 2,
        physical_half_z =
            hub75_p5_64x32_panel_height(panel_obj) / 2,
        rear_edge_x_abs =
            nominal_half_x
            - physical_half_x
            + hub75_p5_64x32_panel_rear_outer_inset_x(panel_obj),
        rear_edge_z_abs =
            nominal_half_z
            - physical_half_z
            + hub75_p5_64x32_panel_rear_outer_inset_z(panel_obj),
        hole_x =
            hub75_p5_64x32_panel_hole_x_positions_centered(panel_obj),
        hole_z =
            hub75_p5_64x32_panel_hole_z_positions_centered(panel_obj),
        screw_x =
            side == "left"
                ? hole_x[0] + nominal_half_x
                : hole_x[1] - nominal_half_x,
        screw_z =
            hole_z[2] - nominal_half_z
    )
    assert(side == "left" || side == "right", "side must be left or right")
    assert(profile_size > 0, "profile_size must be > 0")
    assert(outside_projection > 0, "outside_projection must be > 0")
    assert(outside_projection < 20, "outside projection must remain below 20 mm")
    assert(wall_thickness > 0, "wall_thickness must be > 0")
    assert(fit_clearance >= 0, "fit_clearance must be >= 0")
    assert(base_thickness > 0, "base_thickness must be > 0")
    assert(guide_height >= 0, "guide_height must be >= 0")
    assert(guide_end_rounding >= 0, "guide_end_rounding must be >= 0")
    assert(render_fn >= 24, "render_fn must be >= 24")
    assert(screw_hole_diameter > 0, "screw_hole_diameter must be > 0")
    assert(screw_relief_depth >= 0, "screw_relief_depth must be >= 0")
    assert(screw_relief_radial >= 0, "screw_relief_radial must be >= 0")
    assert(locator_pin_clearance >= 0, "locator pin clearance must be >= 0")
    assert(reference_pocket_diameter > 0, "reference pocket diameter must be > 0")
    assert(reference_pocket_depth >= 0, "reference pocket depth must be >= 0")
    assert(reference_pocket_min_back_wall >= 0, "reference pocket back wall must be >= 0")
    assert(reference_pocket_end_diameter > 0, "reference pocket end diameter must be > 0")
    assert(reference_pocket_end_diameter <= reference_pocket_diameter,
        "reference pocket end diameter must not exceed visible diameter")
    assert(reference_pocket_taper_depth >= 0, "reference pocket taper must be >= 0")
    assert(reference_pocket_taper_depth <= reference_pocket_depth,
        "reference pocket taper must fit inside pocket depth")
    object(
        side = side,
        profile_size = profile_size,
        outside_projection = outside_projection,
        wall_thickness = wall_thickness,
        fit_clearance = fit_clearance,
        base_thickness = base_thickness,
        guide_height = guide_height,
        inside_corner_radius = inside_corner_radius,
        outside_corner_radius = outside_corner_radius,
        guide_end_rounding = guide_end_rounding,
        render_fn = render_fn,

        screw_hole_diameter = screw_hole_diameter,
        screw_relief_depth = screw_relief_depth,
        screw_relief_radial = screw_relief_radial,
        mounting_tube_radial_clearance = mounting_tube_radial_clearance,
        mounting_tube_axial_clearance = mounting_tube_axial_clearance,
        locator_pin_clearance = locator_pin_clearance,

        reinforcement_bushing_clearance = reinforcement_bushing_clearance,
        reinforcement_locator_pad_radial_clearance =
            reinforcement_locator_pad_radial_clearance,
        reinforcement_locator_pad_axial_clearance =
            reinforcement_locator_pad_axial_clearance,
        reinforcement_locator_pin_radial_clearance =
            reinforcement_locator_pin_radial_clearance,
        reinforcement_locator_pin_length =
            reinforcement_locator_pin_length,

        show_reference_pockets = show_reference_pockets,
        reference_pocket_diameter = reference_pocket_diameter,
        reference_pocket_depth = reference_pocket_depth,
        reference_pocket_min_back_wall = reference_pocket_min_back_wall,
        reference_pocket_end_diameter = reference_pocket_end_diameter,
        reference_pocket_taper_depth = reference_pocket_taper_depth,
        reference_pocket_pitch = reference_pocket_pitch,
        reference_pocket_steps = reference_pocket_steps,
        reference_pocket_lane_grid = reference_pocket_lane_grid,
        reference_pocket_lane_fraction = reference_pocket_lane_fraction,
        reference_pocket_edge_margin = reference_pocket_edge_margin,

        show_center_reference_marks = show_center_reference_marks,
        center_mark_depth = center_mark_depth,
        center_mark_pitch = center_mark_pitch,
        center_mark_major_length = center_mark_major_length,
        center_mark_minor_length = center_mark_minor_length,
        center_mark_width = center_mark_width,
        center_mark_cross_length = center_mark_cross_length,
        center_mark_screw_keepout = center_mark_screw_keepout,


        x_inward = x_inward,
        rear_outer_edge_x = x_inward * rear_edge_x_abs,
        rear_outer_edge_z = -rear_edge_z_abs,
        rear_side_rail_width =
            hub75_p5_64x32_panel_rear_side_rail_width_at_mounting_plane(panel_obj),
        rear_end_rail_width =
            hub75_p5_64x32_panel_rear_end_rail_width_at_mounting_plane(panel_obj),
        rear_opening_corner_radius =
            hub75_p5_64x32_panel_rear_opening_corner_radius(panel_obj),
        panel_taper_depth = hub75_rear_taper_depth(panel_obj),
        panel_rear_outer_inset_x =
            hub75_p5_64x32_panel_rear_outer_inset_x(panel_obj),
        panel_rear_outer_inset_z =
            hub75_p5_64x32_panel_rear_outer_inset_z(panel_obj),

        mounting_tube_outer_diameter =
            hub75_p5_64x32_panel_mounting_tube_outer_diameter(panel_obj),
        mounting_tube_protrusion =
            hub75_p5_64x32_panel_mounting_tube_protrusion(panel_obj),

        reinforcement_bushing_outer_diameter =
            hub75_p5_64x32_panel_reinforcement_bushing_outer_diameter(panel_obj),
        reinforcement_bushing_recess_diameter =
            hub75_p5_64x32_panel_reinforcement_bushing_recess_diameter(panel_obj),
        reinforcement_bushing_recess_depth =
            hub75_p5_64x32_panel_reinforcement_bushing_recess_depth(panel_obj),
        reinforcement_bushing_hole_diameter =
            hub75_p5_64x32_panel_reinforcement_bushing_hole_diameter(panel_obj),
        reinforcement_bushing_hole_depth =
            hub75_p5_64x32_panel_reinforcement_bushing_hole_depth(panel_obj),
        reinforcement_bushing_offset =
            hub75_p5_64x32_panel_reinforcement_bushing_offset(panel_obj),

        locator_pin_diameter =
            hub75_p5_64x32_panel_locator_pin_diameter(panel_obj),
        locator_pin_protrusion =
            hub75_p5_64x32_panel_locator_pin_protrusion(panel_obj),
        locator_pin_x_delta =
            hub75_locator_pin_near_edge_screw_x_delta(panel_obj),
        locator_pin_z_delta =
            hub75_locator_pin_edge_screw_z_delta(panel_obj),

        screw_x = screw_x,
        screw_z = screw_z
    );


function hub75_corner_edge_coupler_create_for_size(
    side = "left",
    size = "medium",
    panel_obj = hub75_p5_64x32_panel_create(),
    render_fn = 192,
    show_reference_pockets = true,
    show_center_reference_marks = true
) =
    assert(
        size == "small" || size == "medium" || size == "large",
        str("Unsupported corner-edge coupler size: ", size)
    )
    size == "small"
        ? hub75_corner_edge_coupler_create(
            side = side,
            panel_obj = panel_obj,
            profile_size = 60,
            wall_thickness = 2,
            guide_height = 4,
            base_thickness = 2,
            render_fn = render_fn,
            show_reference_pockets = show_reference_pockets,
            show_center_reference_marks = show_center_reference_marks
        )
        : size == "large"
            ? hub75_corner_edge_coupler_create(
                side = side,
                panel_obj = panel_obj,
                profile_size = 100,
                wall_thickness = 6,
                guide_height = 10,
                base_thickness = 4,
                render_fn = render_fn,
                show_reference_pockets = show_reference_pockets,
                show_center_reference_marks = show_center_reference_marks
            )
            : hub75_corner_edge_coupler_create(
                side = side,
                panel_obj = panel_obj,
                profile_size = 80,
                wall_thickness = 4,
                guide_height = 6,
                base_thickness = 3,
                render_fn = render_fn,
                show_reference_pockets = show_reference_pockets,
                show_center_reference_marks = show_center_reference_marks
            );


function hub75_corner_edge_coupler_inward_reach(coupler_obj) =
    coupler_obj.profile_size / 2;

function hub75_corner_edge_coupler_horizontal_arm_height(coupler_obj) =
    coupler_obj.rear_end_rail_width
    + 2 * (coupler_obj.wall_thickness + coupler_obj.fit_clearance);

function hub75_corner_edge_coupler_vertical_arm_width(coupler_obj) =
    coupler_obj.rear_side_rail_width
    + 2 * (coupler_obj.wall_thickness + coupler_obj.fit_clearance);

function hub75_corner_edge_coupler_side_rail_center_x(coupler_obj) =
    coupler_obj.rear_outer_edge_x
    + coupler_obj.x_inward * coupler_obj.rear_side_rail_width / 2;

function hub75_corner_edge_coupler_end_rail_center_z(coupler_obj) =
    coupler_obj.rear_outer_edge_z
    - coupler_obj.rear_end_rail_width / 2;

function hub75_corner_edge_coupler_screw_position(coupler_obj) =
    [coupler_obj.screw_x, coupler_obj.screw_z];

function hub75_corner_edge_coupler_mounting_tube_pocket_diameter(coupler_obj) =
    coupler_obj.mounting_tube_outer_diameter
    + 2 * coupler_obj.mounting_tube_radial_clearance;

function hub75_corner_edge_coupler_mounting_tube_pocket_depth(coupler_obj) =
    coupler_obj.mounting_tube_protrusion
    + coupler_obj.mounting_tube_axial_clearance;

function hub75_corner_edge_coupler_has_locator_pin(coupler_obj) =
    coupler_obj.side == "left";

function hub75_corner_edge_coupler_locator_pin_position(coupler_obj) =
    [
        coupler_obj.screw_x
            - coupler_obj.x_inward * coupler_obj.locator_pin_x_delta,
        coupler_obj.screw_z
            - coupler_obj.locator_pin_z_delta
    ];

function hub75_corner_edge_coupler_locator_pin_clearance_diameter(coupler_obj) =
    coupler_obj.locator_pin_diameter
    + 2 * coupler_obj.locator_pin_clearance;

function hub75_corner_edge_coupler_reinforcement_position(coupler_obj) =
    [
        coupler_obj.screw_x,
        coupler_obj.screw_z - coupler_obj.reinforcement_bushing_offset
    ];

function hub75_corner_edge_coupler_reinforcement_locator_pad_diameter(coupler_obj) =
    max(
        0.2,
        coupler_obj.reinforcement_bushing_recess_diameter
        - 2 * coupler_obj.reinforcement_locator_pad_radial_clearance
    );

function hub75_corner_edge_coupler_reinforcement_locator_pad_height(coupler_obj) =
    max(
        0.2,
        coupler_obj.reinforcement_bushing_recess_depth
        - coupler_obj.reinforcement_locator_pad_axial_clearance
    );

function hub75_corner_edge_coupler_reinforcement_locator_pin_diameter(coupler_obj) =
    max(
        0.2,
        coupler_obj.reinforcement_bushing_hole_diameter
        - 2 * coupler_obj.reinforcement_locator_pin_radial_clearance
    );

function hub75_corner_edge_coupler_reference_pocket_effective_depth(coupler_obj) =
    max(
        0,
        min(
            coupler_obj.reference_pocket_depth,
            coupler_obj.base_thickness
                - coupler_obj.reference_pocket_min_back_wall
        )
    );


// ----------------------------------------------------------------------
// Public production / design geometry
// ----------------------------------------------------------------------

module hub75_corner_edge_coupler_build(coupler_obj) {
    $fn = coupler_obj.render_fn;

    assert(
        hub75_corner_edge_coupler_horizontal_arm_height(coupler_obj)
            < coupler_obj.profile_size,
        "horizontal corner arm must fit inside profile_size"
    );
    assert(
        hub75_corner_edge_coupler_vertical_arm_width(coupler_obj)
            < coupler_obj.profile_size,
        "vertical corner arm must fit inside profile_size"
    );
    assert(
        hub75_corner_edge_coupler_mounting_tube_pocket_depth(coupler_obj)
            < coupler_obj.base_thickness,
        "mounting-tube pocket must remain blind"
    );
    assert(
        coupler_obj.outside_projection < 20,
        "corner outside projection exceeds project limit"
    );

    union() {
        _hub75_corner_edge_coupler_base_with_surface_details(coupler_obj);

        if (coupler_obj.guide_height > 0)
            _hub75_corner_edge_coupler_guide_walls(coupler_obj);

        if (coupler_obj.guide_height > 0)
            _hub75_corner_edge_coupler_outer_ridges(coupler_obj);

        _hub75_corner_edge_coupler_reinforcement_locator(coupler_obj);
    }
}


module hub75_corner_edge_coupler_render(coupler_obj, view = "final") {
    $fn = coupler_obj.render_fn;

    existing = [0.72, 0.72, 0.72, 1.0];
    existing_transparent = [0.72, 0.72, 0.72, 0.45];
    current = [0.88, 0.08, 0.06, 0.62];
    final_color = [0.72, 0.05, 0.04, 1.0];

    if (view == "functional") {
        color(existing)
            _hub75_corner_edge_coupler_functional_build(coupler_obj);

    } else if (view == "profile") {
        color(current)
            _hub75_corner_edge_coupler_extrude_xz_y(-0.35, 0.35)
                _hub75_corner_edge_coupler_profile_2d(coupler_obj);

    } else if (view == "base") {
        color(current)
            _hub75_corner_edge_coupler_base_solid(coupler_obj);

    } else if (view == "screw-hole") {
        color(existing_transparent)
            _hub75_corner_edge_coupler_base_solid(coupler_obj);
        color(current)
            _hub75_corner_edge_coupler_screw_cutter(coupler_obj);

    } else if (view == "tube-pocket") {
        color(existing)
            _hub75_corner_edge_coupler_base_after_screw_hole(coupler_obj);
        color(current)
            _hub75_corner_edge_coupler_mounting_tube_pocket_cutter(coupler_obj);

    } else if (view == "locator-pin-clearance") {
        color(existing_transparent)
            _hub75_corner_edge_coupler_base_after_pocket(coupler_obj);
        color(current)
            _hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler_obj);

    } else if (view == "guides") {
        color(existing)
            _hub75_corner_edge_coupler_base_after_functional_cutters(coupler_obj);
        color(current) {
            _hub75_corner_edge_coupler_guide_walls(coupler_obj);
            _hub75_corner_edge_coupler_outer_ridges(coupler_obj);
        }

    } else if (view == "reinforcement-locator") {
        color(existing) {
            _hub75_corner_edge_coupler_base_after_functional_cutters(coupler_obj);
            _hub75_corner_edge_coupler_guide_walls(coupler_obj);
            _hub75_corner_edge_coupler_outer_ridges(coupler_obj);
        }
        color(current)
            _hub75_corner_edge_coupler_reinforcement_locator(coupler_obj);

    } else if (view == "reference-pockets") {
        color(existing)
            _hub75_corner_edge_coupler_functional_build(coupler_obj);
        color(current)
            _hub75_corner_edge_coupler_reference_pocket_cutters(coupler_obj);

    } else if (view == "center-marks") {
        color(existing)
            _hub75_corner_edge_coupler_functional_build(coupler_obj);
        color(current) {
            _hub75_corner_edge_coupler_reference_pocket_cutters(coupler_obj);
            _hub75_corner_edge_coupler_center_mark_cutters(coupler_obj);
        }

    } else {
        color(final_color)
            hub75_corner_edge_coupler_build(coupler_obj);
    }
}


// ----------------------------------------------------------------------
// Rounded asymmetric corner profile
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_profile_2d(
    coupler_obj,
    outside_radius_override = undef
) {
    reach = hub75_corner_edge_coupler_inward_reach(coupler_obj);
    x_min =
        coupler_obj.side == "left"
            ? -coupler_obj.outside_projection
            : -reach;
    x_max =
        coupler_obj.side == "left"
            ? reach
            : coupler_obj.outside_projection;
    z_min = -reach;
    z_max = coupler_obj.outside_projection;

    horizontal_arm_height =
        hub75_corner_edge_coupler_horizontal_arm_height(coupler_obj);
    vertical_arm_width =
        hub75_corner_edge_coupler_vertical_arm_width(coupler_obj);
    horizontal_center_z =
        hub75_corner_edge_coupler_end_rail_center_z(coupler_obj);
    vertical_center_x =
        hub75_corner_edge_coupler_side_rail_center_x(coupler_obj);

    vx_left = vertical_center_x - vertical_arm_width / 2;
    vx_right = vertical_center_x + vertical_arm_width / 2;
    z_top = horizontal_center_z + horizontal_arm_height / 2;
    z_bottom = horizontal_center_z - horizontal_arm_height / 2;

    inside_r = min(
        coupler_obj.inside_corner_radius,
        min(
            min(x_max - vx_right, vx_left - x_min),
            min(z_max - z_top, z_bottom - z_min)
        ) - 0.01
    );

    requested_outer =
        is_undef(outside_radius_override)
            ? coupler_obj.outside_corner_radius
            : outside_radius_override;
    outside_r = min(
        requested_outer,
        min(vertical_arm_width, horizontal_arm_height) / 2 - 0.01
    );

    steps = max(24, ceil(coupler_obj.render_fn / 4));

    points = concat(
        [[vx_left + outside_r, z_max], [vx_right - outside_r, z_max]],
        [for (a = [90 : -90 / steps : 0])
            [vx_right - outside_r + outside_r*cos(a),
             z_max - outside_r + outside_r*sin(a)]],

        [[vx_right, z_top + inside_r]],
        [for (a = [180 : 90 / steps : 270])
            [vx_right + inside_r + inside_r*cos(a),
             z_top + inside_r + inside_r*sin(a)]],

        [[x_max - outside_r, z_top]],
        [for (a = [90 : -90 / steps : 0])
            [x_max - outside_r + outside_r*cos(a),
             z_top - outside_r + outside_r*sin(a)]],

        [[x_max, z_bottom + outside_r]],
        [for (a = [0 : -90 / steps : -90])
            [x_max - outside_r + outside_r*cos(a),
             z_bottom + outside_r + outside_r*sin(a)]],

        [[vx_right + inside_r, z_bottom]],
        [for (a = [90 : 90 / steps : 180])
            [vx_right + inside_r + inside_r*cos(a),
             z_bottom - inside_r + inside_r*sin(a)]],

        [[vx_right, z_min + outside_r]],
        [for (a = [0 : -90 / steps : -90])
            [vx_right - outside_r + outside_r*cos(a),
             z_min + outside_r + outside_r*sin(a)]],

        [[vx_left + outside_r, z_min]],
        [for (a = [-90 : -90 / steps : -180])
            [vx_left + outside_r + outside_r*cos(a),
             z_min + outside_r + outside_r*sin(a)]],

        [[vx_left, z_bottom - inside_r]],
        [for (a = [0 : 90 / steps : 90])
            [vx_left - inside_r + inside_r*cos(a),
             z_bottom - inside_r + inside_r*sin(a)]],

        [[x_min + outside_r, z_bottom]],
        [for (a = [-90 : -90 / steps : -180])
            [x_min + outside_r + outside_r*cos(a),
             z_bottom + outside_r + outside_r*sin(a)]],

        [[x_min, z_top - outside_r]],
        [for (a = [180 : -90 / steps : 90])
            [x_min + outside_r + outside_r*cos(a),
             z_top - outside_r + outside_r*sin(a)]],

        [[vx_left - inside_r, z_top]],
        [for (a = [-90 : 90 / steps : 0])
            [vx_left - inside_r + inside_r*cos(a),
             z_top + inside_r + inside_r*sin(a)]],

        [[vx_left, z_max - outside_r]],
        [for (a = [180 : -90 / steps : 90])
            [vx_left + outside_r + outside_r*cos(a),
             z_max - outside_r + outside_r*sin(a)]]
    );

    polygon(points = points);
}


// ----------------------------------------------------------------------
// Reinforcement support envelope
// ----------------------------------------------------------------------

function hub75_corner_edge_coupler_reinforcement_relief_diameter(coupler_obj) =
    coupler_obj.reinforcement_bushing_outer_diameter
    + 2 * coupler_obj.reinforcement_bushing_clearance;

function hub75_corner_edge_coupler_reinforcement_support_diameter(coupler_obj) =
    hub75_corner_edge_coupler_reinforcement_relief_diameter(coupler_obj)
    + 2 * coupler_obj.wall_thickness;

module _hub75_corner_edge_coupler_reinforcement_support_envelope_2d(coupler_obj) {
    position_xz_mm =
        hub75_corner_edge_coupler_reinforcement_position(coupler_obj);

    fg_xf_xzmove([position_xz_mm[0], position_xz_mm[1]])
        circle(
            d = hub75_corner_edge_coupler_reinforcement_support_diameter(coupler_obj)
        );
}

module _hub75_corner_edge_coupler_structural_profile_2d(
    coupler_obj,
    outside_radius_override = undef
) {
    union() {
        _hub75_corner_edge_coupler_profile_2d(
            coupler_obj,
            outside_radius_override = outside_radius_override
        );
        _hub75_corner_edge_coupler_reinforcement_support_envelope_2d(coupler_obj);
    }
}

// ----------------------------------------------------------------------
// Base and functional cutters
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_extrude_xz_y(y_min, y_max) {
    assert(y_max > y_min, "Y extrusion span must be positive");

    fg_xf_frame(
        pos_mm = [0, y_max, 0],
        x_axis = [1, 0, 0],
        y_axis = [0, 0, 1]
    )
        linear_extrude(height = y_max - y_min)
            children();
}


module _hub75_corner_edge_coupler_base_solid(coupler_obj) {
    _hub75_corner_edge_coupler_extrude_xz_y(
        0,
        coupler_obj.base_thickness
    )
        _hub75_corner_edge_coupler_structural_profile_2d(coupler_obj);
}

module _hub75_corner_edge_coupler_through_hole_y_with_relief(
    hole_diameter,
    y_max,
    y_min,
    relief_depth,
    relief_radial,
    x_mm = 0,
    z_mm = 0
) {
    span = y_max - y_min;
    relief_d = hole_diameter + 2 * relief_radial;
    rd = min(
        relief_depth,
        max(0, span / 2 - _HUB75_CORNER_EDGE_COUPLER_EPS)
    );

    // Cylinder local +Z maps to project -Y: bore from y_max toward y_min.
    fg_xf_frame(
        pos_mm = [x_mm, y_max, z_mm],
        x_axis = [1, 0, 0],
        z_axis = [0, -1, 0]
    ) {
        fg_cut_cylinder(
            diameter_mm = hole_diameter,
            height_mm = span,
            overlap = [FG_BOTTOM(), FG_TOP()],
            overlap_mm = _HUB75_CORNER_EDGE_COUPLER_EPS
        );

        if (rd > 0 && relief_radial > 0)
            fg_cut_cylinder(
                diameter_mm = relief_d,
                height_mm = rd,
                overlap = [FG_BOTTOM()],
                overlap_mm = _HUB75_CORNER_EDGE_COUPLER_EPS
            );
    }

    if (rd > 0 && relief_radial > 0)
        fg_xf_frame(
            pos_mm = [x_mm, y_min + rd, z_mm],
            x_axis = [1, 0, 0],
            z_axis = [0, -1, 0]
        )
            fg_cut_cylinder(
                diameter_mm = relief_d,
                height_mm = rd,
                overlap = [FG_TOP()],
                overlap_mm = _HUB75_CORNER_EDGE_COUPLER_EPS
            );
}


module _hub75_corner_edge_coupler_screw_cutter(coupler_obj) {
    _hub75_corner_edge_coupler_through_hole_y_with_relief(
        hole_diameter = coupler_obj.screw_hole_diameter,
        y_max = coupler_obj.base_thickness,
        y_min = 0,
        relief_depth = coupler_obj.screw_relief_depth,
        relief_radial = coupler_obj.screw_relief_radial,
        x_mm = coupler_obj.screw_x,
        z_mm = coupler_obj.screw_z
    );
}


module _hub75_corner_edge_coupler_mounting_tube_pocket_cutter(coupler_obj) {
    pocket_depth =
        hub75_corner_edge_coupler_mounting_tube_pocket_depth(coupler_obj);
    pocket_diameter =
        hub75_corner_edge_coupler_mounting_tube_pocket_diameter(coupler_obj);

    // Pocket enters the coupler from the panel plane along project +Y.
    fg_xf_frame(
        pos_mm = [coupler_obj.screw_x, 0, coupler_obj.screw_z],
        x_axis = [1, 0, 0],
        z_axis = [0, 1, 0]
    )
        fg_cut_cylinder(
            diameter_mm = pocket_diameter,
            height_mm = pocket_depth,
            overlap = [FG_BOTTOM()],
            overlap_mm = _HUB75_CORNER_EDGE_COUPLER_EPS
        );
}


module _hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler_obj) {
    if (hub75_corner_edge_coupler_has_locator_pin(coupler_obj)) {
        position_xz_mm =
            hub75_corner_edge_coupler_locator_pin_position(coupler_obj);

        _hub75_corner_edge_coupler_through_hole_y_with_relief(
            hole_diameter =
                hub75_corner_edge_coupler_locator_pin_clearance_diameter(coupler_obj),
            y_max = coupler_obj.base_thickness,
            y_min = 0,
            relief_depth = coupler_obj.screw_relief_depth,
            relief_radial = coupler_obj.screw_relief_radial,
            x_mm = position_xz_mm[0],
            z_mm = position_xz_mm[1]
        );
    }
}


module _hub75_corner_edge_coupler_base_after_screw_hole(coupler_obj) {
    fg_diff() {
        fg_body()
            _hub75_corner_edge_coupler_base_solid(coupler_obj);

        fg_remove()
            _hub75_corner_edge_coupler_screw_cutter(coupler_obj);
    }
}


module _hub75_corner_edge_coupler_base_after_pocket(coupler_obj) {
    fg_diff() {
        fg_body()
            _hub75_corner_edge_coupler_base_after_screw_hole(coupler_obj);

        fg_remove()
            _hub75_corner_edge_coupler_mounting_tube_pocket_cutter(coupler_obj);
    }
}


module _hub75_corner_edge_coupler_base_after_functional_cutters(coupler_obj) {
    fg_diff() {
        fg_body()
            _hub75_corner_edge_coupler_base_after_pocket(coupler_obj);

        fg_remove()
            _hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler_obj);
    }
}


// ----------------------------------------------------------------------
// Surface reference geometry
// ----------------------------------------------------------------------

function _hub75_corner_edge_coupler_reference_lane_offset(
    coupler_obj,
    virtual_thickness
) =
    max(
        coupler_obj.reference_pocket_lane_grid,
        round(
            virtual_thickness
            * coupler_obj.reference_pocket_lane_fraction
            / coupler_obj.reference_pocket_lane_grid
        )
        * coupler_obj.reference_pocket_lane_grid
    );


function _hub75_corner_edge_coupler_reference_pocket_positions(coupler_obj) =
    let(
        horizontal_height =
            hub75_corner_edge_coupler_horizontal_arm_height(coupler_obj),
        vertical_width =
            hub75_corner_edge_coupler_vertical_arm_width(coupler_obj),
        horizontal_center =
            hub75_corner_edge_coupler_end_rail_center_z(coupler_obj),
        vertical_center =
            hub75_corner_edge_coupler_side_rail_center_x(coupler_obj),
        real_horizontal_inboard =
            horizontal_center - horizontal_height / 2,
        real_vertical_inboard =
            vertical_center
            + coupler_obj.x_inward * vertical_width / 2,
        virtual_horizontal_half = abs(real_horizontal_inboard),
        virtual_vertical_half = abs(real_vertical_inboard),
        common_virtual_half =
            min(virtual_horizontal_half, virtual_vertical_half),
        common_lane =
            _hub75_corner_edge_coupler_reference_lane_offset(
                coupler_obj,
                2 * common_virtual_half
            ),
        shared_edge_inset =
            max(0, common_virtual_half - common_lane),
        horizontal_lane =
            max(0, virtual_horizontal_half - shared_edge_inset),
        vertical_lane =
            max(0, virtual_vertical_half - shared_edge_inset)
    )
    concat(
        [
            for (
                x_direction = [-1, 1],
                step = coupler_obj.reference_pocket_steps,
                lane = [-1, 1]
            )
                [
                    x_direction
                        * step
                        * coupler_obj.reference_pocket_pitch,
                    lane * horizontal_lane
                ]
        ],
        [
            for (
                z_direction = [-1, 1],
                step = coupler_obj.reference_pocket_steps,
                lane = [-1, 1]
            )
                [
                    lane * vertical_lane,
                    z_direction
                        * step
                        * coupler_obj.reference_pocket_pitch
                ]
        ]
    );


module _hub75_corner_edge_coupler_center_marks_2d(coupler_obj) {
    span =
        max(
            hub75_corner_edge_coupler_inward_reach(coupler_obj),
            coupler_obj.outside_projection
        );

    difference() {
        union() {
            // The + marks the nominal 160 x 320 mm panel corner.
            square([
                coupler_obj.center_mark_cross_length,
                coupler_obj.center_mark_width
            ], center = true);
            square([
                coupler_obj.center_mark_width,
                coupler_obj.center_mark_cross_length
            ], center = true);

            for (
                x = [
                    coupler_obj.center_mark_pitch / 2
                    :
                    coupler_obj.center_mark_pitch / 2
                    :
                    span
                ]
            ) {
                major =
                    abs(
                        x / coupler_obj.center_mark_pitch
                        - round(x / coupler_obj.center_mark_pitch)
                    ) < 0.001;
                tick =
                    major
                        ? coupler_obj.center_mark_major_length
                        : coupler_obj.center_mark_minor_length;

                fg_xf_xzmove([x, 0])
                    square([coupler_obj.center_mark_width, tick], center = true);
                fg_xf_xzmove([-x, 0])
                    square([coupler_obj.center_mark_width, tick], center = true);
                fg_xf_xzmove([0, x])
                    square([tick, coupler_obj.center_mark_width], center = true);
                fg_xf_xzmove([0, -x])
                    square([tick, coupler_obj.center_mark_width], center = true);
            }
        }

        fg_xf_xzmove([coupler_obj.screw_x, coupler_obj.screw_z])
            circle(
                r =
                    coupler_obj.screw_hole_diameter / 2
                    + coupler_obj.center_mark_screw_keepout
            );
    }
}


module _hub75_corner_edge_coupler_reference_pocket_cutters(coupler_obj) {
    depth =
        hub75_corner_edge_coupler_reference_pocket_effective_depth(coupler_obj);
    taper_depth =
        min(coupler_obj.reference_pocket_taper_depth, depth);
    straight_depth =
        max(0, depth - taper_depth);

    if (coupler_obj.show_reference_pockets && depth > 0)
        intersection() {
            _hub75_corner_edge_coupler_extrude_xz_y(
                coupler_obj.base_thickness - depth
                    - _HUB75_CORNER_EDGE_COUPLER_EPS,
                coupler_obj.base_thickness
                    + _HUB75_CORNER_EDGE_COUPLER_EPS
            )
                offset(delta = -coupler_obj.reference_pocket_edge_margin)
                    _hub75_corner_edge_coupler_profile_2d(coupler_obj);

            union()
                for (position_xz_mm =
                    _hub75_corner_edge_coupler_reference_pocket_positions(coupler_obj)
                ) {
                    if (straight_depth > 0)
                        fg_xf_frame(
                            pos_mm = [
                                position_xz_mm[0],
                                coupler_obj.base_thickness
                                    + _HUB75_CORNER_EDGE_COUPLER_EPS,
                                position_xz_mm[1]
                            ],
                            x_axis = [1, 0, 0],
                            z_axis = [0, -1, 0]
                        )
                            cylinder(
                                h =
                                    straight_depth
                                    + _HUB75_CORNER_EDGE_COUPLER_EPS,
                                d = coupler_obj.reference_pocket_diameter
                            );

                    if (taper_depth > 0)
                        fg_xf_frame(
                            pos_mm = [
                                position_xz_mm[0],
                                coupler_obj.base_thickness
                                    - straight_depth
                                    + _HUB75_CORNER_EDGE_COUPLER_EPS,
                                position_xz_mm[1]
                            ],
                            x_axis = [1, 0, 0],
                            z_axis = [0, -1, 0]
                        )
                            cylinder(
                                h =
                                    taper_depth
                                    + 2 * _HUB75_CORNER_EDGE_COUPLER_EPS,
                                d1 = coupler_obj.reference_pocket_diameter,
                                d2 = coupler_obj.reference_pocket_end_diameter
                            );
                }
        }
}


module _hub75_corner_edge_coupler_center_mark_cutters(coupler_obj) {
    depth =
        min(
            coupler_obj.center_mark_depth,
            coupler_obj.base_thickness - 0.2
        );

    if (coupler_obj.show_center_reference_marks && depth > 0)
        _hub75_corner_edge_coupler_extrude_xz_y(
            coupler_obj.base_thickness - depth,
            coupler_obj.base_thickness
                + _HUB75_CORNER_EDGE_COUPLER_EPS
        )
            intersection() {
                // The nominal corner itself is the datum, so an additional
                // edge inset would erase the + and the short outside ticks.
                _hub75_corner_edge_coupler_profile_2d(coupler_obj);
                _hub75_corner_edge_coupler_center_marks_2d(coupler_obj);
            }
}


module _hub75_corner_edge_coupler_base_with_surface_details(coupler_obj) {
    fg_diff() {
        fg_body()
            _hub75_corner_edge_coupler_base_after_functional_cutters(coupler_obj);

        fg_remove() {
            _hub75_corner_edge_coupler_reference_pocket_cutters(coupler_obj);
            _hub75_corner_edge_coupler_center_mark_cutters(coupler_obj);
        }
    }
}


// ----------------------------------------------------------------------
// Fitted corner guides
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_panel_keepout_2d(coupler_obj) {
    span = coupler_obj.profile_size + 50;
    side_w = coupler_obj.rear_side_rail_width;
    end_w = coupler_obj.rear_end_rail_width;
    corner_r = coupler_obj.rear_opening_corner_radius;

    // Canonical +U/+V points inward from the physical rear panel corner.
    // Mirroring X supplies left/right; top always maps inward to -Z.
    fg_xf_xzmove([coupler_obj.rear_outer_edge_x, coupler_obj.rear_outer_edge_z])
        scale([coupler_obj.x_inward, -1])
            difference() {
                square([span, span]);

                offset(r = corner_r)
                    offset(delta = -corner_r)
                        translate([side_w, end_w])
                            square([
                                span - side_w + corner_r,
                                span - end_w + corner_r
                            ]);
            }
}


module _hub75_corner_edge_coupler_inside_panel_2d(coupler_obj) {
    span = coupler_obj.profile_size + 50;

    fg_xf_xzmove([coupler_obj.rear_outer_edge_x, coupler_obj.rear_outer_edge_z])
        scale([coupler_obj.x_inward, -1])
            square([span, span]);
}


function _hub75_corner_edge_coupler_effective_guide_rounding(coupler_obj) =
    min(
        coupler_obj.guide_end_rounding,
        max(
            0,
            coupler_obj.wall_thickness / 2
                - _HUB75_CORNER_EDGE_COUPLER_EPS
        )
    );


module _hub75_corner_edge_coupler_guide_shell_2d(coupler_obj) {
    effective_rounding =
        _hub75_corner_edge_coupler_effective_guide_rounding(coupler_obj);

    intersection() {
        difference() {
            _hub75_corner_edge_coupler_structural_profile_2d(coupler_obj);

            offset(delta = coupler_obj.fit_clearance)
                _hub75_corner_edge_coupler_panel_keepout_2d(coupler_obj);
        }

        // This mask can only trim the free ends; it never expands the fitted
        // shell, so the 2 mm small wall cannot be eroded by offset(-r).
        // The reinforcement support envelope remains independent of the
        // cosmetic free-end rounding.
        _hub75_corner_edge_coupler_structural_profile_2d(
            coupler_obj,
            outside_radius_override = effective_rounding
        );
    }
}

module _hub75_corner_edge_coupler_tall_guide_2d(coupler_obj) {
    intersection() {
        _hub75_corner_edge_coupler_guide_shell_2d(coupler_obj);
        _hub75_corner_edge_coupler_inside_panel_2d(coupler_obj);
    }
}


module _hub75_corner_edge_coupler_horizontal_outer_zone_2d(
    coupler_obj,
    panel_shift_z = 0
) {
    span = 2 * coupler_obj.profile_size + 80;
    boundary =
        coupler_obj.rear_outer_edge_z
        + coupler_obj.fit_clearance
        + panel_shift_z;

    fg_xf_xzmove([0, boundary + span / 2])
        square([span, span], center = true);
}


module _hub75_corner_edge_coupler_vertical_outer_zone_2d(
    coupler_obj,
    panel_shift_x = 0
) {
    span = 2 * coupler_obj.profile_size + 80;
    boundary =
        coupler_obj.rear_outer_edge_x
        - coupler_obj.x_inward * (coupler_obj.fit_clearance + panel_shift_x);

    if (coupler_obj.side == "left")
        fg_xf_xzmove([boundary - span / 2, 0])
            square([span, 2 * span], center = true);
    else
        fg_xf_xzmove([boundary + span / 2, 0])
            square([span, 2 * span], center = true);
}


module _hub75_corner_edge_coupler_horizontal_outer_ridge_2d(
    coupler_obj,
    panel_shift_z = 0
) {
    intersection() {
        _hub75_corner_edge_coupler_guide_shell_2d(coupler_obj);
        _hub75_corner_edge_coupler_horizontal_outer_zone_2d(
            coupler_obj,
            panel_shift_z
        );
    }
}


module _hub75_corner_edge_coupler_vertical_outer_ridge_2d(
    coupler_obj,
    panel_shift_x = 0
) {
    intersection() {
        _hub75_corner_edge_coupler_guide_shell_2d(coupler_obj);
        _hub75_corner_edge_coupler_vertical_outer_zone_2d(
            coupler_obj,
            panel_shift_x
        );
    }
}

module _hub75_corner_edge_coupler_guide_walls(coupler_obj) {
    reinforcement =
        hub75_corner_edge_coupler_reinforcement_position(coupler_obj);
    relief_depth = coupler_obj.guide_height + 0.20;

    fg_diff() {
        fg_body()
            _hub75_corner_edge_coupler_extrude_xz_y(
                -coupler_obj.guide_height,
                0
            )
                _hub75_corner_edge_coupler_tall_guide_2d(coupler_obj);

        fg_remove()
            fg_xf_frame(
            pos_mm = [reinforcement[0], 0, reinforcement[1]],
            x_axis = [1, 0, 0],
            z_axis = [0, -1, 0]
        )
                fg_cut_cylinder(
                    diameter_mm =
                        hub75_corner_edge_coupler_reinforcement_relief_diameter(
                            coupler_obj
                        ),
                    height_mm = relief_depth,
                    overlap = [FG_BOTTOM(), FG_TOP()],
                    overlap_mm = _HUB75_CORNER_EDGE_COUPLER_EPS
                );
    }
}

// Clip a straight ridge with the actual linear panel taper. A hull of even
// one ridge would convexify its concave family outline and add diagonal material.
module _hub75_corner_edge_coupler_horizontal_outer_ridge(coupler_obj) {
    ridge_h = coupler_obj.guide_height;
    taper_h = min(ridge_h, coupler_obj.panel_taper_depth);
    shift = hub75_panel_taper_shift_at_depth_mm(
        taper_h, coupler_obj.panel_taper_depth, coupler_obj.panel_rear_outer_inset_z
    );
    boundary = coupler_obj.rear_outer_edge_z + coupler_obj.fit_clearance;
    span = 2 * coupler_obj.profile_size + 80;
    eps = _HUB75_CORNER_EDGE_COUPLER_EPS;

    intersection() {
        _hub75_corner_edge_coupler_extrude_xz_y(-ridge_h, 0)
            _hub75_corner_edge_coupler_horizontal_outer_ridge_2d(coupler_obj);
        // Polygon coordinates are [Y, Z]; remap local X/Y/Z to project Y/Z/X.
        fg_xf_frame(
            x_axis = [0, 1, 0],
            y_axis = [0, 0, 1]
        )
            linear_extrude(height = 2 * span, center = true)
                polygon([
                    [eps, boundary],
                    [0, boundary],
                    [-taper_h, boundary + shift],
                    [-ridge_h - eps, boundary + shift],
                    [-ridge_h - eps, span],
                    [eps, span]
                ]);
    }
}

module _hub75_corner_edge_coupler_vertical_outer_ridge(coupler_obj) {
    ridge_h = coupler_obj.guide_height;
    taper_h = min(ridge_h, coupler_obj.panel_taper_depth);
    shift = hub75_panel_taper_shift_at_depth_mm(
        taper_h, coupler_obj.panel_taper_depth, coupler_obj.panel_rear_outer_inset_x
    );
    boundary = coupler_obj.rear_outer_edge_x
        - coupler_obj.x_inward * coupler_obj.fit_clearance;
    front_boundary = boundary - coupler_obj.x_inward * shift;
    span = 2 * coupler_obj.profile_size + 80;
    outside_x = -coupler_obj.x_inward * span;
    eps = _HUB75_CORNER_EDGE_COUPLER_EPS;

    intersection() {
        _hub75_corner_edge_coupler_extrude_xz_y(-ridge_h, 0)
            _hub75_corner_edge_coupler_vertical_outer_ridge_2d(coupler_obj);
        // Polygon coordinates are [X, Y]; extrude along Z.
        linear_extrude(height = 2 * span, center = true)
            polygon([
                [boundary, eps],
                [boundary, 0],
                [front_boundary, -taper_h],
                [front_boundary, -ridge_h - eps],
                [outside_x, -ridge_h - eps],
                [outside_x, eps]
            ]);
    }
}


module _hub75_corner_edge_coupler_outer_ridges(coupler_obj) {
    // Build the two orthogonal ridges independently. Hulling their union would
    // bridge disconnected corner patches with a diagonal sheet.
    // Only the panel-facing edge of each ridge follows the real panel taper;
    // the exposed outside contour stays on the fixed coupler profile.
    union() {
        _hub75_corner_edge_coupler_horizontal_outer_ridge(coupler_obj);
        _hub75_corner_edge_coupler_vertical_outer_ridge(coupler_obj);
    }
}

// ----------------------------------------------------------------------
// Reinforcement locator
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_reinforcement_locator(coupler_obj) {
    position =
        hub75_corner_edge_coupler_reinforcement_position(coupler_obj);
    pad_d =
        hub75_corner_edge_coupler_reinforcement_locator_pad_diameter(coupler_obj);
    pad_h =
        hub75_corner_edge_coupler_reinforcement_locator_pad_height(coupler_obj);
    pin_d =
        hub75_corner_edge_coupler_reinforcement_locator_pin_diameter(coupler_obj);

    // Both locator cylinders extend from the mounting plane toward project -Y.
    fg_xf_frame(
        pos_mm = [
            position[0],
            _HUB75_CORNER_EDGE_COUPLER_EPS,
            position[1]
        ],
        x_axis = [1, 0, 0],
        z_axis = [0, -1, 0]
    )
        cylinder(
            d = pad_d,
            h = pad_h + _HUB75_CORNER_EDGE_COUPLER_EPS
        );

    fg_xf_frame(
        pos_mm = [
            position[0],
            -pad_h + _HUB75_CORNER_EDGE_COUPLER_EPS,
            position[1]
        ],
        x_axis = [1, 0, 0],
        z_axis = [0, -1, 0]
    )
        cylinder(
            d = pin_d,
            h =
                coupler_obj.reinforcement_locator_pin_length
                + _HUB75_CORNER_EDGE_COUPLER_EPS
        );
}


// ----------------------------------------------------------------------
// Functional construction state
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_functional_build(coupler_obj) {
    union() {
        _hub75_corner_edge_coupler_base_after_functional_cutters(coupler_obj);

        if (coupler_obj.guide_height > 0)
            _hub75_corner_edge_coupler_guide_walls(coupler_obj);

        if (coupler_obj.guide_height > 0)
            _hub75_corner_edge_coupler_outer_ridges(coupler_obj);

        _hub75_corner_edge_coupler_reinforcement_locator(coupler_obj);
    }
}


// ----------------------------------------------------------------------
// Standalone Customizer preview
// ----------------------------------------------------------------------

_preview_panel_obj = hub75_p5_64x32_panel_create();

_preview_coupler_obj =
    hub75_corner_edge_coupler_create(
        side = d_side,
        panel_obj = _preview_panel_obj,
        profile_size = d_profile_size_mm,
        outside_projection = d_outside_projection_mm,
        wall_thickness = d_wall_thickness_mm,
        fit_clearance = d_fit_clearance_mm,
        base_thickness = d_base_thickness_mm,
        guide_height = d_guide_height_mm,
        inside_corner_radius = d_inside_corner_radius_mm,
        outside_corner_radius = d_outside_corner_radius_mm,
        guide_end_rounding = d_guide_end_rounding_mm,
        render_fn = _standalone_render_fn,

        screw_hole_diameter = d_screw_hole_diameter_mm,
        screw_relief_depth = d_screw_relief_depth_mm,
        screw_relief_radial = d_screw_relief_radial_mm,
        mounting_tube_radial_clearance = d_mounting_tube_radial_clearance_mm,
        mounting_tube_axial_clearance = d_mounting_tube_axial_clearance_mm,
        locator_pin_clearance = d_locator_pin_clearance_mm,

        reinforcement_bushing_clearance = d_reinforcement_bushing_clearance_mm,
        reinforcement_locator_pad_radial_clearance =
            d_reinforcement_locator_pad_radial_clearance_mm,
        reinforcement_locator_pad_axial_clearance =
            d_reinforcement_locator_pad_axial_clearance_mm,
        reinforcement_locator_pin_radial_clearance =
            d_reinforcement_locator_pin_radial_clearance_mm,
        reinforcement_locator_pin_length =
            d_reinforcement_locator_pin_length_mm,

        show_reference_pockets = d_show_reference_pockets,
        reference_pocket_diameter = d_reference_pocket_diameter_mm,
        reference_pocket_depth = d_reference_pocket_depth_mm,
        reference_pocket_min_back_wall = d_reference_pocket_min_back_wall_mm,
        reference_pocket_end_diameter = d_reference_pocket_end_diameter_mm,
        reference_pocket_taper_depth = d_reference_pocket_taper_depth_mm,
        reference_pocket_pitch = d_reference_pocket_pitch_mm,
        reference_pocket_steps = d_reference_pocket_steps,
        reference_pocket_lane_grid = d_reference_pocket_lane_grid_mm,
        reference_pocket_lane_fraction = d_reference_pocket_lane_fraction,
        reference_pocket_edge_margin = d_reference_pocket_edge_margin_mm,

        show_center_reference_marks = d_show_center_reference_marks,
        center_mark_depth = d_center_mark_depth_mm,
        center_mark_pitch = d_center_mark_pitch_mm,
        center_mark_major_length = d_center_mark_major_length_mm,
        center_mark_minor_length = d_center_mark_minor_length_mm,
        center_mark_width = d_center_mark_width_mm,
        center_mark_cross_length = d_center_mark_cross_length_mm,
        center_mark_screw_keepout = d_center_mark_screw_keepout_mm
    );

fg_res_apply(c_resolution) {
    hub75_corner_edge_coupler_render(
        _preview_coupler_obj,
        view = c_view
    );
}
