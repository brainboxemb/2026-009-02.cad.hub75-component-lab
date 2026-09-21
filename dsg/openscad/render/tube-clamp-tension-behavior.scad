// Profile comparison of tube-clamp tension semantics.
//
// Left   = functional geometry
// Middle = current tension behavior (smaller bore only)
// Right  = proposed constant-wall tension behavior
//
// Camera looks exactly along clamp-width Z to remove perspective ambiguity.

use <../ext/lib.scad.clamps/openscad/tube-clamp/tube_clamp.scad>
use <../lab_components/tube_clamp_constant_wall.scad>

clamp = tube_clamp_create(
    tube_diameter = 10,
    clearance = 0,
    tension_diameter = 9.6,
    wall_thickness = 2,
    clamp_width = 12,
    opening_angle = 60,
    base_thickness = 0.01,
    transition_width = 5.77,
    transition_depth = 3.6,
    extra = 0.01
);

spacing = 18;
center_x =
    clamp.base_thickness
    + tube_clamp_outer_radius(clamp);

$vpr = [0, 0, 0];
$vpt = [center_x, 0, clamp.clamp_width / 2];
$vpd = 90;

translate([-spacing, 0, 0])
    color([0.72, 0.72, 0.72, 1])
        tube_clamp_build(
            clamp,
            use_tension_bore = false,
            high_resolution = true
        );

color([0.88, 0.08, 0.05, 1])
    tube_clamp_build(
        clamp,
        use_tension_bore = true,
        high_resolution = true
    );

translate([spacing, 0, 0])
    color([0.10, 0.45, 0.85, 1])
        hub75_lab_tube_clamp_constant_wall_build(
            clamp,
            use_tension_bore = true,
            high_resolution = true
        );
