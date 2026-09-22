// File: hub75_corner_edge_coupler.scad
//   Project-specific top-corner coupler for one portrait HUB75 panel.
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
    panel = hub75_p5_64x32_panel_create(),
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
            hub75_p5_64x32_panel_nominal_width(panel) / 2,
        nominal_half_z =
            hub75_p5_64x32_panel_nominal_height(panel) / 2,
        physical_half_x =
            hub75_p5_64x32_panel_width(panel) / 2,
        physical_half_z =
            hub75_p5_64x32_panel_height(panel) / 2,
        rear_edge_x_abs =
            nominal_half_x
            - physical_half_x
            + hub75_p5_64x32_panel_rear_outer_inset_x(panel),
        rear_edge_z_abs =
            nominal_half_z
            - physical_half_z
            + hub75_p5_64x32_panel_rear_outer_inset_z(panel),
        hole_x =
            hub75_p5_64x32_panel_hole_x_positions_centered(panel),
        hole_z =
            hub75_p5_64x32_panel_hole_z_positions_centered(panel),
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
            hub75_p5_64x32_panel_rear_side_rail_width_at_mounting_plane(panel),
        rear_end_rail_width =
            hub75_p5_64x32_panel_rear_end_rail_width_at_mounting_plane(panel),
        rear_opening_corner_radius =
            hub75_p5_64x32_panel_rear_opening_corner_radius(panel),
        panel_taper_depth = hub75_rear_taper_depth(panel),
        panel_rear_outer_inset_x =
            hub75_p5_64x32_panel_rear_outer_inset_x(panel),
        panel_rear_outer_inset_z =
            hub75_p5_64x32_panel_rear_outer_inset_z(panel),

        mounting_tube_outer_diameter =
            hub75_p5_64x32_panel_mounting_tube_outer_diameter(panel),
        mounting_tube_protrusion =
            hub75_p5_64x32_panel_mounting_tube_protrusion(panel),

        reinforcement_bushing_outer_diameter =
            hub75_p5_64x32_panel_reinforcement_bushing_outer_diameter(panel),
        reinforcement_bushing_recess_diameter =
            hub75_p5_64x32_panel_reinforcement_bushing_recess_diameter(panel),
        reinforcement_bushing_recess_depth =
            hub75_p5_64x32_panel_reinforcement_bushing_recess_depth(panel),
        reinforcement_bushing_hole_diameter =
            hub75_p5_64x32_panel_reinforcement_bushing_hole_diameter(panel),
        reinforcement_bushing_hole_depth =
            hub75_p5_64x32_panel_reinforcement_bushing_hole_depth(panel),
        reinforcement_bushing_offset =
            hub75_p5_64x32_panel_reinforcement_bushing_offset(panel),

        locator_pin_diameter =
            hub75_p5_64x32_panel_locator_pin_diameter(panel),
        locator_pin_protrusion =
            hub75_p5_64x32_panel_locator_pin_protrusion(panel),
        locator_pin_x_delta =
            hub75_locator_pin_near_edge_screw_x_delta(panel),
        locator_pin_z_delta =
            hub75_locator_pin_edge_screw_z_delta(panel),

        screw_x = screw_x,
        screw_z = screw_z
    );


function hub75_corner_edge_coupler_create_for_size(
    side = "left",
    size = "medium",
    panel = hub75_p5_64x32_panel_create(),
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
            panel = panel,
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
                panel = panel,
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
                panel = panel,
                profile_size = 80,
                wall_thickness = 4,
                guide_height = 6,
                base_thickness = 3,
                render_fn = render_fn,
                show_reference_pockets = show_reference_pockets,
                show_center_reference_marks = show_center_reference_marks
            );


function hub75_corner_edge_coupler_inward_reach(coupler) =
    coupler.profile_size / 2;

function hub75_corner_edge_coupler_horizontal_arm_height(coupler) =
    coupler.rear_end_rail_width
    + 2 * (coupler.wall_thickness + coupler.fit_clearance);

function hub75_corner_edge_coupler_vertical_arm_width(coupler) =
    coupler.rear_side_rail_width
    + 2 * (coupler.wall_thickness + coupler.fit_clearance);

function hub75_corner_edge_coupler_side_rail_center_x(coupler) =
    coupler.rear_outer_edge_x
    + coupler.x_inward * coupler.rear_side_rail_width / 2;

function hub75_corner_edge_coupler_end_rail_center_z(coupler) =
    coupler.rear_outer_edge_z
    - coupler.rear_end_rail_width / 2;

function hub75_corner_edge_coupler_screw_position(coupler) =
    [coupler.screw_x, coupler.screw_z];

function hub75_corner_edge_coupler_mounting_tube_pocket_diameter(coupler) =
    coupler.mounting_tube_outer_diameter
    + 2 * coupler.mounting_tube_radial_clearance;

function hub75_corner_edge_coupler_mounting_tube_pocket_depth(coupler) =
    coupler.mounting_tube_protrusion
    + coupler.mounting_tube_axial_clearance;

function hub75_corner_edge_coupler_has_locator_pin(coupler) =
    coupler.side == "left";

function hub75_corner_edge_coupler_locator_pin_position(coupler) =
    [
        coupler.screw_x
            - coupler.x_inward * coupler.locator_pin_x_delta,
        coupler.screw_z
            - coupler.locator_pin_z_delta
    ];

function hub75_corner_edge_coupler_locator_pin_clearance_diameter(coupler) =
    coupler.locator_pin_diameter
    + 2 * coupler.locator_pin_clearance;

function hub75_corner_edge_coupler_reinforcement_position(coupler) =
    [
        coupler.screw_x,
        coupler.screw_z - coupler.reinforcement_bushing_offset
    ];

function hub75_corner_edge_coupler_reinforcement_locator_pad_diameter(coupler) =
    max(
        0.2,
        coupler.reinforcement_bushing_recess_diameter
        - 2 * coupler.reinforcement_locator_pad_radial_clearance
    );

function hub75_corner_edge_coupler_reinforcement_locator_pad_height(coupler) =
    max(
        0.2,
        coupler.reinforcement_bushing_recess_depth
        - coupler.reinforcement_locator_pad_axial_clearance
    );

function hub75_corner_edge_coupler_reinforcement_locator_pin_diameter(coupler) =
    max(
        0.2,
        coupler.reinforcement_bushing_hole_diameter
        - 2 * coupler.reinforcement_locator_pin_radial_clearance
    );

function hub75_corner_edge_coupler_reference_pocket_effective_depth(coupler) =
    max(
        0,
        min(
            coupler.reference_pocket_depth,
            coupler.base_thickness
                - coupler.reference_pocket_min_back_wall
        )
    );


// ----------------------------------------------------------------------
// Public production / design geometry
// ----------------------------------------------------------------------

module hub75_corner_edge_coupler_build(coupler) {
    $fn = coupler.render_fn;

    assert(
        hub75_corner_edge_coupler_horizontal_arm_height(coupler)
            < coupler.profile_size,
        "horizontal corner arm must fit inside profile_size"
    );
    assert(
        hub75_corner_edge_coupler_vertical_arm_width(coupler)
            < coupler.profile_size,
        "vertical corner arm must fit inside profile_size"
    );
    assert(
        hub75_corner_edge_coupler_mounting_tube_pocket_depth(coupler)
            < coupler.base_thickness,
        "mounting-tube pocket must remain blind"
    );
    assert(
        coupler.outside_projection < 20,
        "corner outside projection exceeds project limit"
    );

    union() {
        _hub75_corner_edge_coupler_base_with_surface_details(coupler);

        if (coupler.guide_height > 0)
            _hub75_corner_edge_coupler_guide_walls(coupler);

        if (coupler.guide_height > 0)
            _hub75_corner_edge_coupler_outer_ridges(coupler);

        _hub75_corner_edge_coupler_reinforcement_locator(coupler);
    }
}


module hub75_corner_edge_coupler_render(coupler, view = "final") {
    $fn = coupler.render_fn;

    existing = [0.72, 0.72, 0.72, 1.0];
    existing_transparent = [0.72, 0.72, 0.72, 0.45];
    current = [0.88, 0.08, 0.06, 0.62];
    final_color = [0.72, 0.05, 0.04, 1.0];

    if (view == "functional") {
        color(existing)
            _hub75_corner_edge_coupler_functional_build(coupler);

    } else if (view == "profile") {
        color(current)
            _hub75_corner_edge_coupler_extrude_xz_y(-0.35, 0.35)
                _hub75_corner_edge_coupler_profile_2d(coupler);

    } else if (view == "base") {
        color(current)
            _hub75_corner_edge_coupler_base_solid(coupler);

    } else if (view == "screw-hole") {
        color(existing_transparent)
            _hub75_corner_edge_coupler_base_solid(coupler);
        color(current)
            _hub75_corner_edge_coupler_screw_cutter(coupler);

    } else if (view == "tube-pocket") {
        color(existing)
            _hub75_corner_edge_coupler_base_after_screw_hole(coupler);
        color(current)
            _hub75_corner_edge_coupler_mounting_tube_pocket_cutter(coupler);

    } else if (view == "locator-pin-clearance") {
        color(existing_transparent)
            _hub75_corner_edge_coupler_base_after_pocket(coupler);
        color(current)
            _hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler);

    } else if (view == "guides") {
        color(existing)
            _hub75_corner_edge_coupler_base_after_functional_cutters(coupler);
        color(current) {
            _hub75_corner_edge_coupler_guide_walls(coupler);
            _hub75_corner_edge_coupler_outer_ridges(coupler);
        }

    } else if (view == "reinforcement-locator") {
        color(existing) {
            _hub75_corner_edge_coupler_base_after_functional_cutters(coupler);
            _hub75_corner_edge_coupler_guide_walls(coupler);
            _hub75_corner_edge_coupler_outer_ridges(coupler);
        }
        color(current)
            _hub75_corner_edge_coupler_reinforcement_locator(coupler);

    } else if (view == "reference-pockets") {
        color(existing)
            _hub75_corner_edge_coupler_functional_build(coupler);
        color(current)
            _hub75_corner_edge_coupler_reference_pocket_cutters(coupler);

    } else if (view == "center-marks") {
        color(existing)
            _hub75_corner_edge_coupler_functional_build(coupler);
        color(current) {
            _hub75_corner_edge_coupler_reference_pocket_cutters(coupler);
            _hub75_corner_edge_coupler_center_mark_cutters(coupler);
        }

    } else {
        color(final_color)
            hub75_corner_edge_coupler_build(coupler);
    }
}


// ----------------------------------------------------------------------
// Rounded asymmetric corner profile
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_profile_2d(
    coupler,
    outside_radius_override = undef
) {
    reach = hub75_corner_edge_coupler_inward_reach(coupler);
    x_min =
        coupler.side == "left"
            ? -coupler.outside_projection
            : -reach;
    x_max =
        coupler.side == "left"
            ? reach
            : coupler.outside_projection;
    z_min = -reach;
    z_max = coupler.outside_projection;

    horizontal_arm_height =
        hub75_corner_edge_coupler_horizontal_arm_height(coupler);
    vertical_arm_width =
        hub75_corner_edge_coupler_vertical_arm_width(coupler);
    horizontal_center_z =
        hub75_corner_edge_coupler_end_rail_center_z(coupler);
    vertical_center_x =
        hub75_corner_edge_coupler_side_rail_center_x(coupler);

    vx_left = vertical_center_x - vertical_arm_width / 2;
    vx_right = vertical_center_x + vertical_arm_width / 2;
    z_top = horizontal_center_z + horizontal_arm_height / 2;
    z_bottom = horizontal_center_z - horizontal_arm_height / 2;

    inside_r = min(
        coupler.inside_corner_radius,
        min(
            min(x_max - vx_right, vx_left - x_min),
            min(z_max - z_top, z_bottom - z_min)
        ) - 0.01
    );

    requested_outer =
        is_undef(outside_radius_override)
            ? coupler.outside_corner_radius
            : outside_radius_override;
    outside_r = min(
        requested_outer,
        min(vertical_arm_width, horizontal_arm_height) / 2 - 0.01
    );

    steps = max(24, ceil(coupler.render_fn / 4));

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

function hub75_corner_edge_coupler_reinforcement_relief_diameter(coupler) =
    coupler.reinforcement_bushing_outer_diameter
    + 2 * coupler.reinforcement_bushing_clearance;

function hub75_corner_edge_coupler_reinforcement_support_diameter(coupler) =
    hub75_corner_edge_coupler_reinforcement_relief_diameter(coupler)
    + 2 * coupler.wall_thickness;

module _hub75_corner_edge_coupler_reinforcement_support_envelope_2d(coupler) {
    position = hub75_corner_edge_coupler_reinforcement_position(coupler);

    translate(position)
        circle(
            d = hub75_corner_edge_coupler_reinforcement_support_diameter(coupler)
        );
}

module _hub75_corner_edge_coupler_structural_profile_2d(
    coupler,
    outside_radius_override = undef
) {
    union() {
        _hub75_corner_edge_coupler_profile_2d(
            coupler,
            outside_radius_override = outside_radius_override
        );
        _hub75_corner_edge_coupler_reinforcement_support_envelope_2d(coupler);
    }
}

// ----------------------------------------------------------------------
// Base and functional cutters
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_extrude_xz_y(y_min, y_max) {
    assert(y_max > y_min, "Y extrusion span must be positive");

    translate([0, y_max, 0])
        rotate([90, 0, 0])
            linear_extrude(height = y_max - y_min)
                children();
}


module _hub75_corner_edge_coupler_base_solid(coupler) {
    _hub75_corner_edge_coupler_extrude_xz_y(
        0,
        coupler.base_thickness
    )
        _hub75_corner_edge_coupler_structural_profile_2d(coupler);
}

module _hub75_corner_edge_coupler_through_hole_y_with_relief(
    hole_diameter,
    y_max,
    y_min,
    relief_depth,
    relief_radial
) {
    span = y_max - y_min;
    relief_d = hole_diameter + 2 * relief_radial;
    rd = min(
        relief_depth,
        max(0, span / 2 - _HUB75_CORNER_EDGE_COUPLER_EPS)
    );

    translate([
        0,
        y_max + _HUB75_CORNER_EDGE_COUPLER_EPS,
        0
    ])
        rotate([90, 0, 0])
            cylinder(
                d = hole_diameter,
                h = span + 2 * _HUB75_CORNER_EDGE_COUPLER_EPS
            );

    if (rd > 0 && relief_radial > 0) {
        translate([
            0,
            y_max + _HUB75_CORNER_EDGE_COUPLER_EPS,
            0
        ])
            rotate([90, 0, 0])
                cylinder(
                    d = relief_d,
                    h = rd + _HUB75_CORNER_EDGE_COUPLER_EPS
                );

        translate([0, y_min + rd, 0])
            rotate([90, 0, 0])
                cylinder(
                    d = relief_d,
                    h = rd + _HUB75_CORNER_EDGE_COUPLER_EPS
                );
    }
}


module _hub75_corner_edge_coupler_screw_cutter(coupler) {
    translate([coupler.screw_x, 0, coupler.screw_z])
        _hub75_corner_edge_coupler_through_hole_y_with_relief(
            hole_diameter = coupler.screw_hole_diameter,
            y_max = coupler.base_thickness,
            y_min = 0,
            relief_depth = coupler.screw_relief_depth,
            relief_radial = coupler.screw_relief_radial
        );
}


module _hub75_corner_edge_coupler_mounting_tube_pocket_cutter(coupler) {
    pocket_depth =
        hub75_corner_edge_coupler_mounting_tube_pocket_depth(coupler);
    pocket_diameter =
        hub75_corner_edge_coupler_mounting_tube_pocket_diameter(coupler);

    translate([
        coupler.screw_x,
        -_HUB75_CORNER_EDGE_COUPLER_EPS,
        coupler.screw_z
    ])
        rotate([-90, 0, 0])
            cylinder(
                h = pocket_depth + _HUB75_CORNER_EDGE_COUPLER_EPS,
                d = pocket_diameter
            );
}


module _hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler) {
    if (hub75_corner_edge_coupler_has_locator_pin(coupler)) {
        position =
            hub75_corner_edge_coupler_locator_pin_position(coupler);

        translate([position[0], 0, position[1]])
            _hub75_corner_edge_coupler_through_hole_y_with_relief(
                hole_diameter =
                    hub75_corner_edge_coupler_locator_pin_clearance_diameter(coupler),
                y_max = coupler.base_thickness,
                y_min = 0,
                relief_depth = coupler.screw_relief_depth,
                relief_radial = coupler.screw_relief_radial
            );
    }
}


module _hub75_corner_edge_coupler_base_after_screw_hole(coupler) {
    difference() {
        _hub75_corner_edge_coupler_base_solid(coupler);
        _hub75_corner_edge_coupler_screw_cutter(coupler);
    }
}


module _hub75_corner_edge_coupler_base_after_pocket(coupler) {
    difference() {
        _hub75_corner_edge_coupler_base_after_screw_hole(coupler);
        _hub75_corner_edge_coupler_mounting_tube_pocket_cutter(coupler);
    }
}


module _hub75_corner_edge_coupler_base_after_functional_cutters(coupler) {
    difference() {
        _hub75_corner_edge_coupler_base_after_pocket(coupler);
        _hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler);
    }
}


// ----------------------------------------------------------------------
// Surface reference geometry
// ----------------------------------------------------------------------

function _hub75_corner_edge_coupler_reference_lane_offset(
    coupler,
    virtual_thickness
) =
    max(
        coupler.reference_pocket_lane_grid,
        round(
            virtual_thickness
            * coupler.reference_pocket_lane_fraction
            / coupler.reference_pocket_lane_grid
        )
        * coupler.reference_pocket_lane_grid
    );


function _hub75_corner_edge_coupler_reference_pocket_positions(coupler) =
    let(
        horizontal_height =
            hub75_corner_edge_coupler_horizontal_arm_height(coupler),
        vertical_width =
            hub75_corner_edge_coupler_vertical_arm_width(coupler),
        horizontal_center =
            hub75_corner_edge_coupler_end_rail_center_z(coupler),
        vertical_center =
            hub75_corner_edge_coupler_side_rail_center_x(coupler),
        real_horizontal_inboard =
            horizontal_center - horizontal_height / 2,
        real_vertical_inboard =
            vertical_center
            + coupler.x_inward * vertical_width / 2,
        virtual_horizontal_half = abs(real_horizontal_inboard),
        virtual_vertical_half = abs(real_vertical_inboard),
        common_virtual_half =
            min(virtual_horizontal_half, virtual_vertical_half),
        common_lane =
            _hub75_corner_edge_coupler_reference_lane_offset(
                coupler,
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
                step = coupler.reference_pocket_steps,
                lane = [-1, 1]
            )
                [
                    x_direction
                        * step
                        * coupler.reference_pocket_pitch,
                    lane * horizontal_lane
                ]
        ],
        [
            for (
                z_direction = [-1, 1],
                step = coupler.reference_pocket_steps,
                lane = [-1, 1]
            )
                [
                    lane * vertical_lane,
                    z_direction
                        * step
                        * coupler.reference_pocket_pitch
                ]
        ]
    );


module _hub75_corner_edge_coupler_center_marks_2d(coupler) {
    span =
        max(
            hub75_corner_edge_coupler_inward_reach(coupler),
            coupler.outside_projection
        );

    difference() {
        union() {
            // The + marks the nominal 160 x 320 mm panel corner.
            square([
                coupler.center_mark_cross_length,
                coupler.center_mark_width
            ], center = true);
            square([
                coupler.center_mark_width,
                coupler.center_mark_cross_length
            ], center = true);

            for (
                x = [
                    coupler.center_mark_pitch / 2
                    :
                    coupler.center_mark_pitch / 2
                    :
                    span
                ]
            ) {
                major =
                    abs(
                        x / coupler.center_mark_pitch
                        - round(x / coupler.center_mark_pitch)
                    ) < 0.001;
                tick =
                    major
                        ? coupler.center_mark_major_length
                        : coupler.center_mark_minor_length;

                translate([ x, 0])
                    square([coupler.center_mark_width, tick], center = true);
                translate([-x, 0])
                    square([coupler.center_mark_width, tick], center = true);
                translate([0, x])
                    square([tick, coupler.center_mark_width], center = true);
                translate([0,-x])
                    square([tick, coupler.center_mark_width], center = true);
            }
        }

        translate([coupler.screw_x, coupler.screw_z])
            circle(
                r =
                    coupler.screw_hole_diameter / 2
                    + coupler.center_mark_screw_keepout
            );
    }
}


module _hub75_corner_edge_coupler_reference_pocket_cutters(coupler) {
    depth =
        hub75_corner_edge_coupler_reference_pocket_effective_depth(coupler);
    taper_depth =
        min(coupler.reference_pocket_taper_depth, depth);
    straight_depth =
        max(0, depth - taper_depth);

    if (coupler.show_reference_pockets && depth > 0)
        intersection() {
            _hub75_corner_edge_coupler_extrude_xz_y(
                coupler.base_thickness - depth
                    - _HUB75_CORNER_EDGE_COUPLER_EPS,
                coupler.base_thickness
                    + _HUB75_CORNER_EDGE_COUPLER_EPS
            )
                offset(delta = -coupler.reference_pocket_edge_margin)
                    _hub75_corner_edge_coupler_profile_2d(coupler);

            union()
                for (position =
                    _hub75_corner_edge_coupler_reference_pocket_positions(coupler)
                )
                    translate([position[0], 0, position[1]]) {
                        if (straight_depth > 0)
                            translate([
                                0,
                                coupler.base_thickness
                                    + _HUB75_CORNER_EDGE_COUPLER_EPS,
                                0
                            ])
                                rotate([90, 0, 0])
                                    cylinder(
                                        h =
                                            straight_depth
                                            + _HUB75_CORNER_EDGE_COUPLER_EPS,
                                        d = coupler.reference_pocket_diameter
                                    );

                        if (taper_depth > 0)
                            translate([
                                0,
                                coupler.base_thickness
                                    - straight_depth
                                    + _HUB75_CORNER_EDGE_COUPLER_EPS,
                                0
                            ])
                                rotate([90, 0, 0])
                                    cylinder(
                                        h =
                                            taper_depth
                                            + 2 * _HUB75_CORNER_EDGE_COUPLER_EPS,
                                        d1 = coupler.reference_pocket_diameter,
                                        d2 = coupler.reference_pocket_end_diameter
                                    );
                    }
        }
}


module _hub75_corner_edge_coupler_center_mark_cutters(coupler) {
    depth =
        min(
            coupler.center_mark_depth,
            coupler.base_thickness - 0.2
        );

    if (coupler.show_center_reference_marks && depth > 0)
        _hub75_corner_edge_coupler_extrude_xz_y(
            coupler.base_thickness - depth,
            coupler.base_thickness
                + _HUB75_CORNER_EDGE_COUPLER_EPS
        )
            intersection() {
                // The nominal corner itself is the datum, so an additional
                // edge inset would erase the + and the short outside ticks.
                _hub75_corner_edge_coupler_profile_2d(coupler);
                _hub75_corner_edge_coupler_center_marks_2d(coupler);
            }
}


module _hub75_corner_edge_coupler_base_with_surface_details(coupler) {
    difference() {
        _hub75_corner_edge_coupler_base_after_functional_cutters(coupler);
        _hub75_corner_edge_coupler_reference_pocket_cutters(coupler);
        _hub75_corner_edge_coupler_center_mark_cutters(coupler);
    }
}


// ----------------------------------------------------------------------
// Fitted corner guides
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_panel_keepout_2d(coupler) {
    span = coupler.profile_size + 50;
    side_w = coupler.rear_side_rail_width;
    end_w = coupler.rear_end_rail_width;
    corner_r = coupler.rear_opening_corner_radius;

    // Canonical +U/+V points inward from the physical rear panel corner.
    // Mirroring X supplies left/right; top always maps inward to -Z.
    translate([
        coupler.rear_outer_edge_x,
        coupler.rear_outer_edge_z
    ])
        scale([coupler.x_inward, -1])
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


module _hub75_corner_edge_coupler_inside_panel_2d(coupler) {
    span = coupler.profile_size + 50;

    translate([
        coupler.rear_outer_edge_x,
        coupler.rear_outer_edge_z
    ])
        scale([coupler.x_inward, -1])
            square([span, span]);
}


function _hub75_corner_edge_coupler_effective_guide_rounding(coupler) =
    min(
        coupler.guide_end_rounding,
        max(
            0,
            coupler.wall_thickness / 2
                - _HUB75_CORNER_EDGE_COUPLER_EPS
        )
    );


module _hub75_corner_edge_coupler_guide_shell_2d(coupler) {
    effective_rounding =
        _hub75_corner_edge_coupler_effective_guide_rounding(coupler);

    intersection() {
        difference() {
            _hub75_corner_edge_coupler_structural_profile_2d(coupler);

            offset(delta = coupler.fit_clearance)
                _hub75_corner_edge_coupler_panel_keepout_2d(coupler);
        }

        // This mask can only trim the free ends; it never expands the fitted
        // shell, so the 2 mm small wall cannot be eroded by offset(-r).
        // The reinforcement support envelope remains independent of the
        // cosmetic free-end rounding.
        _hub75_corner_edge_coupler_structural_profile_2d(
            coupler,
            outside_radius_override = effective_rounding
        );
    }
}

module _hub75_corner_edge_coupler_tall_guide_2d(coupler) {
    intersection() {
        _hub75_corner_edge_coupler_guide_shell_2d(coupler);
        _hub75_corner_edge_coupler_inside_panel_2d(coupler);
    }
}


module _hub75_corner_edge_coupler_horizontal_outer_zone_2d(
    coupler,
    panel_shift_z = 0
) {
    span = 2 * coupler.profile_size + 80;
    boundary =
        coupler.rear_outer_edge_z
        + coupler.fit_clearance
        + panel_shift_z;

    translate([0, boundary + span / 2])
        square([span, span], center = true);
}


module _hub75_corner_edge_coupler_vertical_outer_zone_2d(
    coupler,
    panel_shift_x = 0
) {
    span = 2 * coupler.profile_size + 80;
    boundary =
        coupler.rear_outer_edge_x
        - coupler.x_inward * (coupler.fit_clearance + panel_shift_x);

    if (coupler.side == "left")
        translate([boundary - span / 2, 0])
            square([span, 2 * span], center = true);
    else
        translate([boundary + span / 2, 0])
            square([span, 2 * span], center = true);
}


module _hub75_corner_edge_coupler_horizontal_outer_ridge_2d(
    coupler,
    panel_shift_z = 0
) {
    intersection() {
        _hub75_corner_edge_coupler_guide_shell_2d(coupler);
        _hub75_corner_edge_coupler_horizontal_outer_zone_2d(
            coupler,
            panel_shift_z
        );
    }
}


module _hub75_corner_edge_coupler_vertical_outer_ridge_2d(
    coupler,
    panel_shift_x = 0
) {
    intersection() {
        _hub75_corner_edge_coupler_guide_shell_2d(coupler);
        _hub75_corner_edge_coupler_vertical_outer_zone_2d(
            coupler,
            panel_shift_x
        );
    }
}

module _hub75_corner_edge_coupler_guide_walls(coupler) {
    reinforcement =
        hub75_corner_edge_coupler_reinforcement_position(coupler);

    difference() {
        _hub75_corner_edge_coupler_extrude_xz_y(
            -coupler.guide_height,
            0
        )
            _hub75_corner_edge_coupler_tall_guide_2d(coupler);

        translate([
            reinforcement[0],
            _HUB75_CORNER_EDGE_COUPLER_EPS,
            reinforcement[1]
        ])
            rotate([90, 0, 0])
                cylinder(
                    d =
                        hub75_corner_edge_coupler_reinforcement_relief_diameter(
                            coupler
                        ),
                    h =
                        coupler.guide_height
                        + 0.30
                );
    }
}

// Clip a straight ridge with the actual linear panel taper. A hull of even
// one ridge would convexify its concave family outline and add diagonal material.
module _hub75_corner_edge_coupler_horizontal_outer_ridge(coupler) {
    ridge_h = coupler.guide_height;
    taper_h = min(ridge_h, coupler.panel_taper_depth);
    shift = hub75_panel_taper_shift_at_depth_mm(
        taper_h, coupler.panel_taper_depth, coupler.panel_rear_outer_inset_z
    );
    boundary = coupler.rear_outer_edge_z + coupler.fit_clearance;
    span = 2 * coupler.profile_size + 80;
    eps = _HUB75_CORNER_EDGE_COUPLER_EPS;

    intersection() {
        _hub75_corner_edge_coupler_extrude_xz_y(-ridge_h, 0)
            _hub75_corner_edge_coupler_horizontal_outer_ridge_2d(coupler);
        // Polygon coordinates are [Y, Z]; extrude along X.
        multmatrix([[0,0,1,0], [1,0,0,0], [0,1,0,0], [0,0,0,1]])
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

module _hub75_corner_edge_coupler_vertical_outer_ridge(coupler) {
    ridge_h = coupler.guide_height;
    taper_h = min(ridge_h, coupler.panel_taper_depth);
    shift = hub75_panel_taper_shift_at_depth_mm(
        taper_h, coupler.panel_taper_depth, coupler.panel_rear_outer_inset_x
    );
    boundary = coupler.rear_outer_edge_x
        - coupler.x_inward * coupler.fit_clearance;
    front_boundary = boundary - coupler.x_inward * shift;
    span = 2 * coupler.profile_size + 80;
    outside_x = -coupler.x_inward * span;
    eps = _HUB75_CORNER_EDGE_COUPLER_EPS;

    intersection() {
        _hub75_corner_edge_coupler_extrude_xz_y(-ridge_h, 0)
            _hub75_corner_edge_coupler_vertical_outer_ridge_2d(coupler);
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


module _hub75_corner_edge_coupler_outer_ridges(coupler) {
    // Build the two orthogonal ridges independently. Hulling their union would
    // bridge disconnected corner patches with a diagonal sheet.
    // Only the panel-facing edge of each ridge follows the real panel taper;
    // the exposed outside contour stays on the fixed coupler profile.
    union() {
        _hub75_corner_edge_coupler_horizontal_outer_ridge(coupler);
        _hub75_corner_edge_coupler_vertical_outer_ridge(coupler);
    }
}

// ----------------------------------------------------------------------
// Reinforcement locator
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_reinforcement_locator(coupler) {
    position =
        hub75_corner_edge_coupler_reinforcement_position(coupler);
    pad_d =
        hub75_corner_edge_coupler_reinforcement_locator_pad_diameter(coupler);
    pad_h =
        hub75_corner_edge_coupler_reinforcement_locator_pad_height(coupler);
    pin_d =
        hub75_corner_edge_coupler_reinforcement_locator_pin_diameter(coupler);

    translate([
        position[0],
        _HUB75_CORNER_EDGE_COUPLER_EPS,
        position[1]
    ])
        rotate([90, 0, 0])
            cylinder(
                d = pad_d,
                h = pad_h + _HUB75_CORNER_EDGE_COUPLER_EPS
            );

    translate([
        position[0],
        -pad_h + _HUB75_CORNER_EDGE_COUPLER_EPS,
        position[1]
    ])
        rotate([90, 0, 0])
            cylinder(
                d = pin_d,
                h =
                    coupler.reinforcement_locator_pin_length
                    + _HUB75_CORNER_EDGE_COUPLER_EPS
            );
}


// ----------------------------------------------------------------------
// Functional construction state
// ----------------------------------------------------------------------

module _hub75_corner_edge_coupler_functional_build(coupler) {
    union() {
        _hub75_corner_edge_coupler_base_after_functional_cutters(coupler);

        if (coupler.guide_height > 0)
            _hub75_corner_edge_coupler_guide_walls(coupler);

        if (coupler.guide_height > 0)
            _hub75_corner_edge_coupler_outer_ridges(coupler);

        _hub75_corner_edge_coupler_reinforcement_locator(coupler);
    }
}


// ----------------------------------------------------------------------
// Standalone Customizer preview
// ----------------------------------------------------------------------

_preview_panel = hub75_p5_64x32_panel_create();

_preview_coupler =
    hub75_corner_edge_coupler_create(
        side = d_side,
        panel = _preview_panel,
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

fg_res_apply(c_resolution)
    hub75_corner_edge_coupler_render(
    _preview_coupler,
    view = c_view
    );
