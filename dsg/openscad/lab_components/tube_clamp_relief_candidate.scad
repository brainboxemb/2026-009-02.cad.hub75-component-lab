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

    // Development-coordinate location of the lower transition foot:
    //
    // native profile foot:
    //   x = base_thickness
    //   y = +/- transition_width/2
    //
    // after project + development transforms:
    //   X = +/- clamp_width/2  (the two clamp end faces)
    //   Y = native profile Y - tube_center_z
    //   Z = tube_center_y + outer radius
    //
    // Put the R10 centre directly on the clamp end-face line in X, but mostly
    // outside the profile in Y.  The circle therefore enters the material by
    // only 'bite' at the marked transition-foot corner.  The cylinder is low
    // in Z, matching the user's marked development-orientation sketch.
    target_z =
        clamp.tube_center_y
        + outer_r;

    for (face_side = [-1, 1])
        for (profile_side = [-1, 1]) {
            target_x =
                face_side
                * b.clamp_width / 2;
            target_y =
                profile_side
                * b.transition_width / 2
                - clamp.tube_center_z;
            cutter_y =
                target_y
                + profile_side
                    * (radius - bite);

            translate([
                target_x,
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
