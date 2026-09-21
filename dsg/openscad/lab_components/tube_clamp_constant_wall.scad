// Lab-only prototype for tension behavior with constant wall thickness.
//
// This intentionally does not modify lib.scad.clamps yet.  The experiment keeps
// the nominal clamp centre fixed and shrinks both inner and outer radii when the
// tension diameter is selected.

use <../ext/lib.scad.clamps/openscad/tube-clamp/tube_clamp.scad>

function hub75_lab_tube_clamp_active_inner_radius(
    clamp,
    use_tension_bore
) =
    tube_clamp_bore_radius(
        clamp,
        use_tension_bore
    );

function hub75_lab_tube_clamp_active_outer_radius(
    clamp,
    use_tension_bore
) =
    hub75_lab_tube_clamp_active_inner_radius(
        clamp,
        use_tension_bore
    )
    + clamp.wall_thickness;

// Keep the ring centre fixed on the functional design datum.  Only the radii
// change between functional and tension geometry.
function hub75_lab_tube_clamp_nominal_center_x(clamp) =
    clamp.base_thickness
    + tube_clamp_outer_radius(clamp);

module _hub75_lab_constant_wall_outer_ring(
    clamp,
    use_tension_bore
) {
    translate([
        hub75_lab_tube_clamp_nominal_center_x(clamp),
        0,
        0
    ])
        cylinder(
            h = clamp.clamp_width,
            r = hub75_lab_tube_clamp_active_outer_radius(
                clamp,
                use_tension_bore
            )
        );
}

module _hub75_lab_constant_wall_flat_base(clamp) {
    translate([
        0,
        -clamp.transition_width / 2,
        0
    ])
        cube([
            clamp.base_thickness + clamp.extra,
            clamp.transition_width,
            clamp.clamp_width
        ]);
}

module _hub75_lab_constant_wall_transition(
    clamp,
    use_tension_bore
) {
    outer_r =
        hub75_lab_tube_clamp_active_outer_radius(
            clamp,
            use_tension_bore
        );
    center_x =
        hub75_lab_tube_clamp_nominal_center_x(clamp);

    attach_x = min(
        clamp.base_thickness + clamp.transition_depth,
        center_x + outer_r - clamp.extra
    );

    dx = attach_x - center_x;
    attach_y = sqrt(max(
        0.01,
        outer_r * outer_r - dx * dx
    ));

    base_half_width = clamp.transition_width / 2;

    linear_extrude(height = clamp.clamp_width)
        polygon(points = [
            [clamp.base_thickness, -base_half_width],
            [clamp.base_thickness,  base_half_width],
            [attach_x,               attach_y],
            [attach_x,              -attach_y]
        ]);
}

module _hub75_lab_constant_wall_outer_shape(
    clamp,
    use_tension_bore
) {
    union() {
        _hub75_lab_constant_wall_outer_ring(
            clamp,
            use_tension_bore
        );
        _hub75_lab_constant_wall_flat_base(clamp);
        _hub75_lab_constant_wall_transition(
            clamp,
            use_tension_bore
        );
    }
}

module _hub75_lab_constant_wall_bore(
    clamp,
    use_tension_bore
) {
    translate([
        hub75_lab_tube_clamp_nominal_center_x(clamp),
        0,
        -clamp.extra
    ])
        cylinder(
            h = clamp.clamp_width
                + 2 * clamp.extra,
            r = hub75_lab_tube_clamp_active_inner_radius(
                clamp,
                use_tension_bore
            )
        );
}

module _hub75_lab_constant_wall_opening(
    clamp,
    use_tension_bore
) {
    outer_r =
        hub75_lab_tube_clamp_active_outer_radius(
            clamp,
            use_tension_bore
        );
    cutter_length = outer_r + 10;
    cutter_half_width =
        cutter_length
        * tan(clamp.opening_angle / 2);

    translate([
        hub75_lab_tube_clamp_nominal_center_x(clamp),
        0,
        -clamp.extra
    ])
        linear_extrude(
            height =
                clamp.clamp_width
                + 2 * clamp.extra
        )
            polygon(points = [
                [0, 0],
                [cutter_length, -cutter_half_width],
                [cutter_length,  cutter_half_width]
            ]);
}

module hub75_lab_tube_clamp_constant_wall_build(
    clamp,
    use_tension_bore = true,
    high_resolution = true
) {
    $fn = high_resolution ? 120 : 48;

    difference() {
        _hub75_lab_constant_wall_outer_shape(
            clamp,
            use_tension_bore
        );

        _hub75_lab_constant_wall_bore(
            clamp,
            use_tension_bore
        );

        _hub75_lab_constant_wall_opening(
            clamp,
            use_tension_bore
        );
    }
}
