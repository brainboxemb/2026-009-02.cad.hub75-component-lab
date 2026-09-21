// Lab-only candidate modifier for the HUB75 tube clamp.
//
// The parent component is always built with its production transition relief
// disabled.  This file performs the experiment entirely in the standardized
// development orientation:
//
//   dovetail mounting/root plane = XY
//   local experiment cutter axis = Z
//
// Once accepted, only the resulting geometric rule is translated back into
// parent-project coordinates.

use <../lab_orientation.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>
use <../ext/lib.scad.clamps/openscad/tube-clamp/tube_clamp.scad>

module hub75_lab_tube_clamp_baseline(
    clamp,
    use_tension_bore = false,
    high_resolution = true,
    part_color = [0.72, 0.72, 0.72, 1]
) {
    hub75_lab_development_orientation()
        hub75_tube_clamp_build(
            clamp,
            part_color = part_color,
            use_tension_bore = use_tension_bore,
            high_resolution = high_resolution,
            apply_transition_relief = false
        );
}

module hub75_lab_tube_clamp_relief_cutter(
    clamp,
    radius = 10,
    bite = 1,
    depth = 2,
    high_resolution = true
) {
    b = clamp.base_clamp;

    assert(radius > 0, "lab relief radius must be > 0");
    assert(bite >= 0 && bite <= radius,
        "lab relief bite must be between 0 and radius");
    assert(depth > 0, "lab relief depth must be > 0");

    outer_r = tube_clamp_outer_radius(b);
    ring_center_x = b.base_thickness + outer_r;
    attach_x = min(
        b.base_thickness + b.transition_depth,
        ring_center_x + outer_r - b.extra
    );
    attach_dx = attach_x - ring_center_x;
    attach_y = sqrt(max(
        0.01,
        outer_r * outer_r - attach_dx * attach_dx
    ));

    // Development-coordinate target = the sharp transition -> ring corner
    // highlighted in the user's green markup.
    //
    // Native attach point:
    //   x = attach_x
    //   y = +/- attach_y
    //
    // Upright development coordinates:
    //   X = +/- clamp_width/2
    //   Y = tube_center_z - native_y
    //   Z = native_x - (tube_center_y + ring_center_x)
    target_z =
        attach_x
        - clamp.tube_center_y
        - ring_center_x;

    // Keep most of the R10 circle outside BOTH intersecting side boundaries.
    // The centre is moved along the outward 45-degree bisector.  Its radial
    // distance from the marked corner is radius-bite, so the maximum local
    // penetration at that corner is approximately 'bite'.
    radial_offset = radius - bite;
    axis_offset = radial_offset / sqrt(2);

    for (face_side = [-1, 1])
        for (profile_side = [-1, 1]) {
            target_x =
                face_side
                * b.clamp_width / 2;
            target_y =
                clamp.tube_center_z
                - profile_side * attach_y;

            cutter_x =
                target_x
                + face_side * axis_offset;
            cutter_y =
                target_y
                - profile_side * axis_offset;

            translate([
                cutter_x,
                cutter_y,
                target_z - depth / 2
            ])
                cylinder(
                    r = radius,
                    h = depth,
                    $fn = high_resolution ? 96 : 32
                );
        }
}

module hub75_lab_tube_clamp_candidate(
    clamp,
    radius = 10,
    bite = 1,
    depth = 2,
    use_tension_bore = false,
    high_resolution = true,
    part_color = [0.88, 0.08, 0.05, 1]
) {
    color(part_color)
        difference() {
            hub75_lab_tube_clamp_baseline(
                clamp,
                use_tension_bore = use_tension_bore,
                high_resolution = high_resolution,
                part_color = [1, 1, 1, 1]
            );

            hub75_lab_tube_clamp_relief_cutter(
                clamp,
                radius = radius,
                bite = bite,
                depth = depth,
                high_resolution = high_resolution
            );
        }
}
