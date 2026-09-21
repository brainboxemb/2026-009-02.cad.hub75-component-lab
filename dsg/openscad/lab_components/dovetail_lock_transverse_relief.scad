// Lab fixture for the female dovetail lock transverse relief.
//
// Builds a neutral host using the real HUB75 interface object and project
// transform.  The optional thin section passes through the short transverse
// spring opening so its print-oriented Y/Z profile is directly visible.

use <../project_components/tube_mount/tube_mount_interface.scad>

function hub75_lab_lock_fixture_section_project_z(
    dovetail,
    slide = 16
) =
    let(
        female_slide =
            hub75_tube_mount_dovetail_female_slide(
                dovetail,
                slide
            )
    )
    female_slide / 2
    + dovetail.lock.spring.relief / 2;

module hub75_lab_lock_transverse_relief_fixture(
    size = "medium",
    shape = "rectangular",
    angle = 45,
    slide = 16
) {
    dovetail =
        hub75_tube_mount_dovetail_create_for_size(
            size,
            lock_spring_transverse_relief_shape = shape,
            lock_spring_transverse_relief_angle = angle
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
    angle = 45,
    slide = 16,
    section_thickness = 0.45
) {
    dovetail =
        hub75_tube_mount_dovetail_create_for_size(
            size,
            lock_spring_transverse_relief_shape = shape,
            lock_spring_transverse_relief_angle = angle
        );

    section_z =
        hub75_lab_lock_fixture_section_project_z(
            dovetail,
            slide
        );

    intersection() {
        hub75_lab_lock_transverse_relief_fixture(
            size = size,
            shape = shape,
            angle = angle,
            slide = slide
        );

        translate([
            -50,
            -50,
            section_z - section_thickness / 2
        ])
            cube([
                100,
                100,
                section_thickness
            ]);
    }
}
