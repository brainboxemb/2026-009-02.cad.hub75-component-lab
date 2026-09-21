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

module hub75_lab_tube_clamp_relief_probe(
    clamp,
    radius = 10,
    depth = 2,
    high_resolution = true
) {
    b = clamp.base_clamp;
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

    // Diagnostic only:
    // one single transition -> ring attach point, no symmetry and no cutting.
    //
    // Clamp extrusion/project-X becomes development-X.  Use the middle of that
    // width so the probe cannot accidentally be interpreted as an end-face
    // feature again.
    probe_x = 0;

    // Select the profile side corresponding to the visible marked side.
    probe_y =
        clamp.tube_center_z
        - attach_y;

    probe_z =
        attach_x
        - clamp.tube_center_y
        - ring_center_x;

    color([0.05, 0.90, 0.15, 0.65])
        translate([
            probe_x,
            probe_y,
            probe_z - depth / 2
        ])
            cylinder(
                r = radius,
                h = depth,
                $fn = high_resolution ? 96 : 32
            );
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
    // Until the target location is visually confirmed, the candidate is kept
    // identical to the baseline.  Do not subtract a speculative cutter.
    hub75_lab_tube_clamp_baseline(
        clamp,
        use_tension_bore = use_tension_bore,
        high_resolution = high_resolution,
        part_color = part_color
    );
}
