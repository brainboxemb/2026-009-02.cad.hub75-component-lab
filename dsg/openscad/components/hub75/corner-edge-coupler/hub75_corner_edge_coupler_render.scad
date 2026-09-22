// File: hub75_corner_edge_coupler_render.scad
// Design-documentation adapter for the corner-edge coupler.
// Explanatory construction states decompose production geometry visually.

use <../../../ext/lib.scad.forge/openscad/resolution.scad>
use <hub75_corner_edge_coupler.scad>

module _hub75_corner_edge_design_thin(y_min = -0.35, y_max = 0.35) {
    rotate([90, 0, 0])
        _hub75_corner_edge_coupler_extrude_xz_y(y_min, y_max)
            children();
}

module _hub75_corner_edge_design_horizontal_arm_2d(coupler) {
    reach = hub75_corner_edge_coupler_inward_reach(coupler);
    x_min = coupler.side == "left" ? -coupler.outside_projection : -reach;
    x_max = coupler.side == "left" ? reach : coupler.outside_projection;
    translate([
        (x_min + x_max) / 2,
        hub75_corner_edge_coupler_end_rail_center_z(coupler)
    ])
        square([
            x_max - x_min,
            hub75_corner_edge_coupler_horizontal_arm_height(coupler)
        ], center = true);
}

module _hub75_corner_edge_design_vertical_arm_2d(coupler) {
    reach = hub75_corner_edge_coupler_inward_reach(coupler);
    z_min = -reach;
    z_max = coupler.outside_projection;
    translate([
        hub75_corner_edge_coupler_side_rail_center_x(coupler),
        (z_min + z_max) / 2
    ])
        square([
            hub75_corner_edge_coupler_vertical_arm_width(coupler),
            z_max - z_min
        ], center = true);
}

module _hub75_corner_edge_design_raw_cross_2d(coupler) {
    union() {
        _hub75_corner_edge_design_horizontal_arm_2d(coupler);
        _hub75_corner_edge_design_vertical_arm_2d(coupler);
    }
}

module _hub75_corner_edge_design_end_rail_2d(coupler) {
    reach = hub75_corner_edge_coupler_inward_reach(coupler);
    x_min = coupler.side == "left" ? -coupler.outside_projection : -reach;
    x_max = coupler.side == "left" ? reach : coupler.outside_projection;
    translate([
        (x_min + x_max) / 2,
        hub75_corner_edge_coupler_end_rail_center_z(coupler)
    ])
        square([x_max - x_min + 6, coupler.rear_end_rail_width], center = true);
}

module _hub75_corner_edge_design_profile_window_2d(coupler) {
    reach = hub75_corner_edge_coupler_inward_reach(coupler);
    x_min = coupler.side == "left" ? -coupler.outside_projection : -reach;
    x_max = coupler.side == "left" ? reach : coupler.outside_projection;
    z_min = -reach;
    z_max = coupler.outside_projection;
    translate([(x_min + x_max) / 2, (z_min + z_max) / 2])
        square([x_max - x_min + 10, z_max - z_min + 10], center = true);
}

module _hub75_corner_edge_design_panel_keepout_visible_2d(coupler) {
    intersection() {
        _hub75_corner_edge_coupler_panel_keepout_2d(coupler);
        _hub75_corner_edge_design_profile_window_2d(coupler);
    }
}

module _hub75_corner_edge_design_clearance_band_2d(coupler) {
    difference() {
        intersection() {
            offset(delta = coupler.fit_clearance)
                _hub75_corner_edge_coupler_panel_keepout_2d(coupler);
            _hub75_corner_edge_design_profile_window_2d(coupler);
        }
        _hub75_corner_edge_design_panel_keepout_visible_2d(coupler);
    }
}

module _hub75_corner_edge_design_profile_outline_2d(coupler, line_width = 1.0) {
    difference() {
        _hub75_corner_edge_coupler_profile_2d(coupler);
        offset(delta = -line_width)
            _hub75_corner_edge_coupler_profile_2d(coupler);
    }
}

module _hub75_corner_edge_design_raw_guide_shell_2d(coupler) {
    difference() {
        _hub75_corner_edge_coupler_structural_profile_2d(coupler);
        offset(delta = coupler.fit_clearance)
            _hub75_corner_edge_coupler_panel_keepout_2d(coupler);
    }
}

module _hub75_corner_edge_design_outer_ridges_2d(
    coupler,
    panel_shift_x = 0,
    panel_shift_z = 0
) {
    union() {
        _hub75_corner_edge_coupler_horizontal_outer_ridge_2d(
            coupler,
            panel_shift_z
        );
        _hub75_corner_edge_coupler_vertical_outer_ridge_2d(
            coupler,
            panel_shift_x
        );
    }
}

module _hub75_corner_edge_design_straight_outer_ridges(coupler) {
    _hub75_corner_edge_coupler_extrude_xz_y(-coupler.guide_height, 0)
        _hub75_corner_edge_design_outer_ridges_2d(coupler);
}

module _hub75_corner_edge_design_reinforcement_relief_cutter(coupler) {
    eps = 0.05;
    position = hub75_corner_edge_coupler_reinforcement_position(coupler);
    relief_diameter =
        hub75_corner_edge_coupler_reinforcement_relief_diameter(coupler);
    translate([position[0], eps, position[1]])
        rotate([90, 0, 0])
            cylinder(d = relief_diameter, h = coupler.guide_height + 0.30);
}

module _hub75_corner_edge_design_unrelieved_tall_guide(coupler) {
    _hub75_corner_edge_coupler_extrude_xz_y(-coupler.guide_height, 0)
        _hub75_corner_edge_coupler_tall_guide_2d(coupler);
}

module _hub75_corner_edge_design_reinforcement_crop(
    coupler,
    position,
    crop_width = 34,
    crop_height = 34
) {
    translate([
        position[0] - crop_width / 2,
        -coupler.guide_height - 2,
        position[1] - crop_height / 2
    ])
        cube([crop_width, coupler.guide_height + 3, crop_height]);
}

module _hub75_corner_edge_design_reinforcement_panel_fragment(
    coupler,
    position,
    fragment_length = 24,
    fragment_depth = 6.5
) {
    outer_d = coupler.reinforcement_bushing_outer_diameter;
    recess_d = coupler.reinforcement_bushing_recess_diameter;
    recess_depth = coupler.reinforcement_bushing_recess_depth;
    hole_d = coupler.reinforcement_bushing_hole_diameter;
    hole_depth = coupler.reinforcement_bushing_hole_depth;
    rail_width = coupler.rear_side_rail_width;
    eps = 0.04;

    translate([position[0], 0, position[1]])
        difference() {
            _hub75_corner_edge_coupler_extrude_xz_y(-fragment_depth, 0)
                union() {
                    square([rail_width, fragment_length], center = true);
                    circle(d = outer_d);
                }
            _hub75_corner_edge_coupler_extrude_xz_y(-recess_depth - eps, eps)
                circle(d = recess_d);
            _hub75_corner_edge_coupler_extrude_xz_y(
                -recess_depth - hole_depth,
                -recess_depth + eps
            )
                circle(d = hole_d);
        }
}

module _hub75_corner_edge_design_reinforcement_guide_fragment(coupler, position) {
    intersection() {
        _hub75_corner_edge_design_unrelieved_tall_guide(coupler);
        _hub75_corner_edge_design_reinforcement_crop(coupler, position);
    }
}

module _hub75_corner_edge_design_reinforcement_clearance_band(coupler, position) {
    outer_d =
        coupler.reinforcement_bushing_outer_diameter
        + 2 * coupler.reinforcement_bushing_clearance;
    inner_d = coupler.reinforcement_bushing_outer_diameter;
    translate([position[0], 0, position[1]])
        difference() {
            _hub75_corner_edge_coupler_extrude_xz_y(-coupler.guide_height, 0)
                circle(d = outer_d);
            _hub75_corner_edge_coupler_extrude_xz_y(-coupler.guide_height - 0.05, 0.05)
                circle(d = inner_d);
        }
}

module _hub75_corner_edge_design_reinforcement_collision(coupler, position) {
    intersection() {
        _hub75_corner_edge_design_reinforcement_guide_fragment(coupler, position);
        _hub75_corner_edge_design_reinforcement_relief_cutter(coupler);
    }
}

module _hub75_corner_edge_design_physical_locator_pin(coupler) {
    position = hub75_corner_edge_coupler_locator_pin_position(coupler);
    translate([position[0], 0, position[1]])
        rotate([-90, 0, 0])
            cylinder(d = coupler.locator_pin_diameter, h = coupler.locator_pin_protrusion);
}

module _hub75_corner_edge_design_locator_crop(coupler, width = 34) {
    position = hub75_corner_edge_coupler_locator_pin_position(coupler);
    translate([
        position[0] - width / 2,
        -2,
        position[1] - width / 2
    ])
        cube([width, coupler.base_thickness + 5, width]);
}

module _hub75_corner_edge_design_after_reference_pockets(coupler) {
    union() {
        difference() {
            _hub75_corner_edge_coupler_base_after_functional_cutters(coupler);
            _hub75_corner_edge_coupler_reference_pocket_cutters(coupler);
        }
        if (coupler.guide_height > 0) {
            _hub75_corner_edge_coupler_guide_walls(coupler);
            _hub75_corner_edge_coupler_outer_ridges(coupler);
        }
        _hub75_corner_edge_coupler_reinforcement_locator(coupler);
    }
}

module hub75_corner_edge_coupler_design(view = "final") {
    small = hub75_corner_edge_coupler_create_for_size(side = "left", size = "small");
    medium = hub75_corner_edge_coupler_create_for_size(side = "left", size = "medium");
    large = hub75_corner_edge_coupler_create_for_size(side = "left", size = "large");
    right_medium = hub75_corner_edge_coupler_create_for_size(side = "right", size = "medium");
    coupler =
        view == "locator-pin-clearance"
            ? large
            : view == "reinforcement-support-profile"
                ? small
                : medium;

    existing = [0.56, 0.56, 0.56, 1.0];
    existing_transparent = [0.56, 0.56, 0.56, 0.42];
    current = [0.88, 0.08, 0.06, 0.68];

    if (view == "mating-reference") {
        color(current)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_design_clearance_band_2d(coupler);
        color(existing)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_design_panel_keepout_visible_2d(coupler);

    } else if (view == "profile-horizontal-arm") {
        color(current)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_design_horizontal_arm_2d(coupler);
        color(existing)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_design_end_rail_2d(coupler);

    } else if (view == "profile-vertical-arm") {
        color(current)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_design_vertical_arm_2d(coupler);
        color(existing)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_design_horizontal_arm_2d(coupler);

    } else if (view == "profile-raw-cross") {
        color(current)
            _hub75_corner_edge_design_thin()
                _hub75_corner_edge_design_raw_cross_2d(coupler);

    } else if (view == "profile-rounded") {
        color(existing_transparent)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_design_raw_cross_2d(coupler);
        color(current)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_coupler_profile_2d(coupler);

    } else if (view == "reinforcement-support-profile") {
        color(existing)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_coupler_profile_2d(coupler);
        color(current)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                difference() {
                    _hub75_corner_edge_coupler_structural_profile_2d(coupler);
                    _hub75_corner_edge_coupler_profile_2d(coupler);
                }

    } else if (view == "locator-pin-clearance") {
        position = hub75_corner_edge_coupler_locator_pin_position(coupler);
        translate([10, 0, -10])
            scale([2.25, 2.25, 2.25])
                translate([-position[0], 0, -position[1]]) {
                    color(existing_transparent)
                        intersection() {
                            _hub75_corner_edge_coupler_base_after_pocket(coupler);
                            _hub75_corner_edge_design_locator_crop(coupler);
                        }
                    color([0.43, 0.43, 0.43, 1.0])
                        _hub75_corner_edge_design_physical_locator_pin(coupler);
                    color([0.88, 0.08, 0.06, 0.30])
                        _hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler);
                }

    } else if (view == "guide-keepout") {
        color(current)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                intersection() {
                    _hub75_corner_edge_coupler_profile_2d(coupler);
                    offset(delta = coupler.fit_clearance)
                        _hub75_corner_edge_coupler_panel_keepout_2d(coupler);
                }
        color(existing)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_design_profile_outline_2d(coupler);

    } else if (view == "guide-raw-shell") {
        color(existing_transparent)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_coupler_profile_2d(coupler);
        color(current)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_design_raw_guide_shell_2d(coupler);

    } else if (view == "guide-end-mask") {
        color(existing_transparent)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_design_raw_guide_shell_2d(coupler);
        color(current)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_coupler_guide_shell_2d(coupler);

    } else if (view == "guide-zones") {
        color(existing)
            _hub75_corner_edge_design_thin(-0.42, -0.02)
                _hub75_corner_edge_coupler_tall_guide_2d(coupler);
        color(current)
            _hub75_corner_edge_design_thin(0.02, 0.42)
                _hub75_corner_edge_design_outer_ridges_2d(coupler);

    } else if (view == "guide-taper") {
        // Disjoint solids expose the taper operation without coincident
        // transparent surfaces hiding the thin panel-facing wedge.
        color(existing)
            _hub75_corner_edge_coupler_outer_ridges(coupler);
        color(current)
            difference() {
                _hub75_corner_edge_design_straight_outer_ridges(coupler);
                _hub75_corner_edge_coupler_outer_ridges(coupler);
            }

    } else if (view == "guide-reinforcement-relief") {
        detail_position = hub75_corner_edge_coupler_reinforcement_position(coupler);
        translate([10, 0, -10])
            scale([1.75, 1.75, 1.75])
                translate([-detail_position[0], 0, -detail_position[1]]) {
                    color(existing_transparent)
                        _hub75_corner_edge_design_unrelieved_tall_guide(coupler);
                    color(current)
                        _hub75_corner_edge_design_reinforcement_relief_cutter(coupler);
                }

    } else if (view == "guide-reinforcement-detail") {
        detail_position = hub75_corner_edge_coupler_reinforcement_position(coupler);
        translate([10, 0, -2])
            scale([2.2, 2.2, 2.2])
                translate([-detail_position[0], 0, -detail_position[1]]) {
                    color([0.43, 0.43, 0.43, 1.0])
                        _hub75_corner_edge_design_reinforcement_panel_fragment(coupler, detail_position);
                    color([0.72, 0.72, 0.72, 0.48])
                        _hub75_corner_edge_design_reinforcement_guide_fragment(coupler, detail_position);
                    color([0.88, 0.08, 0.06, 0.30])
                        _hub75_corner_edge_design_reinforcement_clearance_band(coupler, detail_position);
                    color([0.94, 0.03, 0.02, 0.96])
                        _hub75_corner_edge_design_reinforcement_collision(coupler, detail_position);
                }

    } else if (view == "center-marks") {
        color(existing)
            _hub75_corner_edge_design_after_reference_pockets(coupler);
        color(current)
            _hub75_corner_edge_coupler_center_mark_cutters(coupler);

    } else if (view == "right-final") {
        hub75_corner_edge_coupler_render(right_medium, view = "final");

    } else {
        hub75_corner_edge_coupler_render(coupler, view = view);
    }
}

fg_res_apply(FG_RES_HIGH())
    hub75_corner_edge_coupler_design();
