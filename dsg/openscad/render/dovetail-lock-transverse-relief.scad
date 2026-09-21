// Print-oriented comparison of the female lock transverse opening.
//
// Left  = released rectangular opening
// Right = candidate trapezoid at 45 degrees
//
// Project X is mapped to print +Z.  The thin section passes through the short
// transverse spring relief so the overhang-relevant opening profile is visible.

use <../lab_orientation.scad>
use <../lab_components/dovetail_lock_transverse_relief.scad>

profile = "medium";
angle = 45;
section_thickness = 0.45;
spacing = 9;

$vpt = [0, 0.5, 0];
$vpr = [90, 0, 90];
$vpd = 62;

translate([0, -spacing / 2, 0])
    color([0.72, 0.72, 0.72, 1])
        hub75_lab_print_orientation()
            hub75_lab_lock_transverse_relief_section(
                size = profile,
                shape = "rectangular",
                angle = angle,
                section_thickness =
                    section_thickness
            );

translate([0, spacing / 2, 0])
    color([0.88, 0.08, 0.05, 1])
        hub75_lab_print_orientation()
            hub75_lab_lock_transverse_relief_section(
                size = profile,
                shape = "trapezoid",
                angle = angle,
                section_thickness =
                    section_thickness
            );
