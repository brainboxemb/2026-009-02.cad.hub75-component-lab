// Lab-only candidate modifier for the HUB75 tube clamp.
//
// The parent component is built with its production transition relief disabled.
// This experiment is applied directly in the standardized development
// orientation:
//
//   dovetail mounting/root plane = XY
//   local relief-cylinder axis   = Z
//
// Confirmed calibration:
//   clamp width = 12 mm
//   radius      = 5 mm
//   bite        = 1 mm
//
// Therefore the cylinder centres sit at:
//   abs(X) = clamp_width/2 + radius - bite = 10 mm
//
// Once accepted, only this geometric rule is translated back into the parent
// project.

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
    radius = 5,
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

    // Confirmed position from the visual calibration.
    cutter_x =
        b.clamp_width / 2
        + radius
        - bite;

    cutter_y = clamp.tube_center_z;

    cutter_z =
        attach_x
        - clamp.tube_center_y
        - ring_center_x;

    // Same shallow local cut on both clamp sides.
    for (side = [-1, 1])
        translate([
            side * cutter_x,
            cutter_y,
            cutter_z - depth / 2
        ])
            cylinder(
                r = radius,
                h = depth,
                $fn = high_resolution ? 96 : 32
            );
}

module hub75_lab_tube_clamp_relief_probe(
    clamp,
    radius = 5,
    bite = 1,
    depth = 2,
    high_resolution = true
) {
    color([0.05, 0.90, 0.15, 0.65])
        hub75_lab_tube_clamp_relief_cutter(
            clamp,
            radius = radius,
            bite = bite,
            depth = depth,
            high_resolution = high_resolution
        );
}

module hub75_lab_tube_clamp_candidate(
    clamp,
    radius = 5,
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
