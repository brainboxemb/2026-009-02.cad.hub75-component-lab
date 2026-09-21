// Print-oriented X/Z section through the female lock transverse opening.
//
// Left  = released rectangular opening
// Right = candidate trapezoid, broad at print -Z and narrower at print +Z.
//
// The thin section is through project Y, which exposes mechint native X/Z.

use <../lab_orientation.scad>
use <../lab_components/dovetail_lock_transverse_relief.scad>

profile = "medium";
top_length = 0.4;
section_thickness = 0.45;
spacing = 18;

$vpt = [0, 0, 0];
$vpr = [90, 0, 0];
$vpd = 78;

translate([-spacing / 2, 0, 0])
    color([0.72, 0.72, 0.72, 1])
        hub75_lab_print_orientation()
            hub75_lab_lock_transverse_relief_section(
                size = profile,
                shape = "rectangular",
                section_thickness = section_thickness
            );

translate([spacing / 2, 0, 0])
    color([0.88, 0.08, 0.05, 1])
        hub75_lab_print_orientation()
            hub75_lab_lock_transverse_relief_section(
                size = profile,
                shape = "trapezoid",
                top_length = top_length,
                section_thickness = section_thickness
            );
