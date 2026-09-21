// Lab fixture for the female dovetail lock transverse relief.
//
// The candidate trapezoid is defined in mechint native X/Z:
//   native Z = intended print/build direction
//   native X = transverse-opening length
//
// The full fixture uses the actual HUB75 interface transform. The thin section
// is taken through project Y so the native X/Z opening profile is visible.

use <../project_components/tube_mount/tube_mount_interface.scad>

function hub75_lab_lock_transverse_relief_section_project_y(
    dovetail
) =
    hub75_tube_mount_dovetail_mouth_y()
    + sliding_dovetail_female_height(dovetail)
    + (
        dovetail.lock.spring.thickness
        + (dovetail.lock.spring.cut_back_clearance
            ? dovetail.lock.spring.back_clearance
            : 0)
    ) / 2;

module hub75_lab_lock_transverse_relief_fixture(
    size = "medium",
    shape = "rectangular",
    top_length = undef,
    slide = 16
) {
    dovetail =
        hub75_tube_mount_dovetail_create_for_size(
            size,
            lock_spring_transverse_relief_shape = shape,
            lock_spring_transverse_relief_top_length =
                top_length
        );

    female_slide =
        hub75_tube_mount_dovetail_female_slide(
            dovetail,
            slide
        );
    entry_slot =
        hub75_tube_mount_dovetail_entry_slot_length(
            dovetail
        );
    root_width =
        hub75_tube_mount_dovetail_female_root_width(
            dovetail
        );

    mouth_y =
        hub75_tube_mount_dovetail_mouth_y();
    host_depth =
        hub75_tube_mount_host_depth_for_size(size);

    margin_x = 2;
    margin_z = 2;

    block_x = root_width + 2 * margin_x;
    z_min = -female_slide / 2 - margin_z;
    z_max =
        female_slide / 2
        + entry_slot
        + margin_z;

    difference() {
        translate([
            -block_x / 2,
            mouth_y,
            z_min
        ])
            cube([
                block_x,
                host_depth - mouth_y,
                z_max - z_min
            ]);

        hub75_tube_mount_dovetail_female_cutter(
            dovetail,
            slide = slide
        );
    }
}

module hub75_lab_lock_transverse_relief_section(
    size = "medium",
    shape = "rectangular",
    top_length = undef,
    slide = 16,
    section_thickness = 0.45
) {
    dovetail =
        hub75_tube_mount_dovetail_create_for_size(
            size,
            lock_spring_transverse_relief_shape = shape,
            lock_spring_transverse_relief_top_length =
                top_length
        );

    section_y =
        hub75_lab_lock_transverse_relief_section_project_y(
            dovetail
        );

    intersection() {
        hub75_lab_lock_transverse_relief_fixture(
            size = size,
            shape = shape,
            top_length = top_length,
            slide = slide
        );

        translate([
            -50,
            section_y - section_thickness / 2,
            -50
        ])
            cube([
                100,
                section_thickness,
                100
            ]);
    }
}
