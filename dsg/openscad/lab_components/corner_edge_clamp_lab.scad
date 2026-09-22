// File: corner_edge_clamp_lab.scad
//   Focused workbench for the HUB75 corner-edge coupler and detachable tube clamp.
//
// This file owns diagnostic presentation only. Production geometry is delegated
// to the frozen parent-source snapshot and the released reusable libraries.

use <../ext/lib.scad.forge/openscad/resolution.scad>
use <../components/hub75/corner-edge-coupler/hub75_corner_edge_coupler.scad>
use <../project_components/tube_mount/corner-edge-coupler/hub75_tube_corner_edge_coupler.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

_HUB75_LAB_CORNER_EPS_MM = 0.05;

function hub75_lab_corner_edge_coupler_create(
    side = "left",
    size = "medium"
) =
    hub75_corner_edge_coupler_create_for_size(
        side = side,
        size = size
    );

function hub75_lab_corner_edge_clamp_create(coupler) =
    hub75_tube_clamp_create(
        dovetail =
            hub75_tube_mount_dovetail_create(
                host_depth_mm = coupler.base_thickness
            )
    );

module _hub75_lab_corner_edge_core_raw(coupler) {
    hub75_corner_edge_coupler_build(coupler);
}

module _hub75_lab_corner_edge_tube_mount_raw(
    coupler,
    resolution
) {
    hub75_tube_corner_edge_coupler_build(
        coupler,
        resolution = resolution
    );
}

module _hub75_lab_corner_edge_total_removed_raw(
    coupler,
    resolution
) {
    difference() {
        _hub75_lab_corner_edge_core_raw(coupler);
        _hub75_lab_corner_edge_tube_mount_raw(
            coupler,
            resolution
        );
    }
}

module _hub75_lab_corner_edge_tube_keepout_cutter(
    coupler,
    clamp
) {
    keepout_diameter_mm =
        hub75_tube_clamp_functional_diameter_mm(clamp)
        + 2
            * hub75_tube_corner_edge_keepout_radial_clearance_mm(
                coupler
            );
    cutter_length_mm =
        coupler.profile_size
        + 2 * coupler.outside_projection
        + 2 * _HUB75_LAB_CORNER_EPS_MM;

    translate([
        -cutter_length_mm / 2,
        hub75_tube_clamp_tube_center_y_mm(clamp),
        hub75_tube_clamp_tube_center_z_mm(clamp)
    ])
        rotate([0, 90, 0])
            cylinder(
                d = keepout_diameter_mm,
                h = cutter_length_mm
            );
}

module _hub75_lab_corner_edge_dovetail_cutter(
    coupler,
    clamp
) {
    hub75_tube_mount_dovetail_female_cutter(
        clamp.dovetail,
        slide_len_mm = clamp.dovetail_slide_len_mm,
        center_x_mm =
            hub75_tube_corner_edge_clamp_x_mm(coupler),
        center_z_mm = clamp.dovetail_center_z_mm
    );
}

module _hub75_lab_corner_edge_feature_in_core(
    coupler
) {
    intersection() {
        _hub75_lab_corner_edge_core_raw(coupler);
        children();
    }
}

module hub75_lab_corner_edge_core(
    coupler,
    part_color = [0.72, 0.72, 0.72, 1]
) {
    color(part_color)
        _hub75_lab_corner_edge_core_raw(coupler);
}

module hub75_lab_corner_edge_tube_mount(
    coupler,
    resolution = FG_RES_HIGH(),
    part_color = [0.72, 0.05, 0.04, 1]
) {
    color(part_color)
        _hub75_lab_corner_edge_tube_mount_raw(
            coupler,
            resolution
        );
}

module hub75_lab_corner_edge_clamp(
    coupler,
    clamp,
    z_shift_mm = 0,
    resolution = FG_RES_HIGH(),
    part_color = [0.92, 0.20, 0.08, 1]
) {
    translate([
        hub75_tube_corner_edge_clamp_x_mm(coupler),
        0,
        z_shift_mm
    ])
        hub75_tube_clamp_build(
            clamp,
            part_color = part_color,
            use_tension_bore = false,
            resolution = resolution
        );
}

module hub75_lab_corner_edge_tube(
    coupler,
    clamp,
    z_shift_mm = 0,
    resolution = FG_RES_HIGH(),
    part_color = [0.72, 0.74, 0.76, 0.35]
) {
    tube_length_mm =
        coupler.profile_size
        + 2 * coupler.outside_projection
        + 20;
    tube_diameter_mm =
        hub75_tube_clamp_functional_diameter_mm(clamp);

    color(part_color)
        translate([
            -tube_length_mm / 2,
            hub75_tube_clamp_tube_center_y_mm(clamp),
            hub75_tube_clamp_tube_center_z_mm(clamp)
                + z_shift_mm
        ])
            rotate([0, 90, 0])
                cylinder(
                    d = tube_diameter_mm,
                    h = tube_length_mm,
                    $fn = resolution == FG_RES_LOW() ? 48 : 160
                );
}

module hub75_lab_corner_edge_removed(
    coupler,
    resolution = FG_RES_HIGH()
) {
    color([0.72, 0.72, 0.72, 0.22])
        _hub75_lab_corner_edge_core_raw(coupler);

    color([0.88, 0.08, 0.05, 1])
        _hub75_lab_corner_edge_total_removed_raw(
            coupler,
            resolution
        );
}

module hub75_lab_corner_edge_tube_keepout(
    coupler,
    clamp
) {
    color([0.72, 0.72, 0.72, 0.22])
        _hub75_lab_corner_edge_core_raw(coupler);

    color([0.10, 0.45, 0.85, 1])
        _hub75_lab_corner_edge_feature_in_core(coupler)
            _hub75_lab_corner_edge_tube_keepout_cutter(
                coupler,
                clamp
            );
}

module hub75_lab_corner_edge_dovetail(
    coupler,
    clamp
) {
    color([0.72, 0.72, 0.72, 0.22])
        _hub75_lab_corner_edge_core_raw(coupler);

    color([0.88, 0.08, 0.05, 1])
        _hub75_lab_corner_edge_feature_in_core(coupler)
            _hub75_lab_corner_edge_dovetail_cutter(
                coupler,
                clamp
            );
}

module hub75_lab_corner_edge_clamp_access(
    coupler,
    clamp,
    resolution = FG_RES_HIGH()
) {
    color([0.72, 0.72, 0.72, 0.22])
        _hub75_lab_corner_edge_core_raw(coupler);

    color([0.88, 0.08, 0.05, 1])
        difference() {
            _hub75_lab_corner_edge_total_removed_raw(
                coupler,
                resolution
            );

            _hub75_lab_corner_edge_tube_keepout_cutter(
                coupler,
                clamp
            );

            _hub75_lab_corner_edge_dovetail_cutter(
                coupler,
                clamp
            );
        }
}


// ----------------------------------------------------------------------
// Focused section evidence
// ----------------------------------------------------------------------

module _hub75_lab_corner_edge_slice_at_z(
    z_mm,
    thickness_mm = 0.6
) {
    span_mm = 240;
    active_thickness_mm = max(0.1, thickness_mm);

    intersection() {
        children();
        translate([0, 0, z_mm])
            cube(
                [
                    span_mm,
                    span_mm,
                    active_thickness_mm
                ],
                center = true
            );
    }
}


module _hub75_lab_corner_edge_slice_at_x(
    x_mm,
    thickness_mm = 0.6
) {
    span_mm = 240;
    active_thickness_mm = max(0.1, thickness_mm);

    intersection() {
        children();
        translate([x_mm, 0, 0])
            cube(
                [
                    active_thickness_mm,
                    span_mm,
                    span_mm
                ],
                center = true
            );
    }
}


module hub75_lab_corner_edge_dovetail_profile(
    coupler,
    clamp,
    section_thickness_mm = 0.6
) {
    section_z_mm = clamp.dovetail_center_z_mm;

    color([0.72, 0.72, 0.72, 1])
        _hub75_lab_corner_edge_slice_at_z(
            section_z_mm,
            section_thickness_mm
        )
            difference() {
                _hub75_lab_corner_edge_core_raw(coupler);
                _hub75_lab_corner_edge_dovetail_cutter(
                    coupler,
                    clamp
                );
            }

    color([0.88, 0.08, 0.05, 1])
        _hub75_lab_corner_edge_slice_at_z(
            section_z_mm,
            section_thickness_mm
        )
            _hub75_lab_corner_edge_feature_in_core(coupler)
                _hub75_lab_corner_edge_dovetail_cutter(
                    coupler,
                    clamp
                );
}


module hub75_lab_corner_edge_access_section(
    coupler,
    clamp,
    resolution = FG_RES_HIGH(),
    section_thickness_mm = 0.6
) {
    section_x_mm =
        hub75_tube_corner_edge_clamp_x_mm(coupler);

    color([0.72, 0.72, 0.72, 1])
        _hub75_lab_corner_edge_slice_at_x(
            section_x_mm,
            section_thickness_mm
        )
            _hub75_lab_corner_edge_tube_mount_raw(
                coupler,
                resolution
            );

    color([0.88, 0.08, 0.05, 1])
        _hub75_lab_corner_edge_slice_at_x(
            section_x_mm,
            section_thickness_mm
        )
            difference() {
                _hub75_lab_corner_edge_total_removed_raw(
                    coupler,
                    resolution
                );

                _hub75_lab_corner_edge_tube_keepout_cutter(
                    coupler,
                    clamp
                );

                _hub75_lab_corner_edge_dovetail_cutter(
                    coupler,
                    clamp
                );
            }

    color([0.10, 0.45, 0.85, 1])
        _hub75_lab_corner_edge_slice_at_x(
            section_x_mm,
            section_thickness_mm
        )
            _hub75_lab_corner_edge_feature_in_core(coupler)
                _hub75_lab_corner_edge_tube_keepout_cutter(
                    coupler,
                    clamp
                );
}

module hub75_lab_corner_edge_clamp_view(
    side = "left",
    size = "medium",
    view = "assembly",
    explode_distance_mm = 0,
    show_tube = true,
    resolution = FG_RES_HIGH()
) {
    coupler =
        hub75_lab_corner_edge_coupler_create(
            side = side,
            size = size
        );
    clamp =
        hub75_lab_corner_edge_clamp_create(coupler);
    clamp_z_shift_mm =
        view == "exploded"
            ? max(0, explode_distance_mm)
            : 0;
    tube_z_shift_mm =
        view == "exploded"
            ? 0.65 * max(0, explode_distance_mm)
            : 0;

    if (view == "core")
        hub75_lab_corner_edge_core(coupler);
    else if (view == "tube_mount")
        hub75_lab_corner_edge_tube_mount(
            coupler,
            resolution = resolution
        );
    else if (view == "removed")
        hub75_lab_corner_edge_removed(
            coupler,
            resolution = resolution
        );
    else if (view == "tube_keepout")
        hub75_lab_corner_edge_tube_keepout(
            coupler,
            clamp
        );
    else if (view == "dovetail")
        hub75_lab_corner_edge_dovetail(
            coupler,
            clamp
        );
    else if (view == "dovetail_profile")
        hub75_lab_corner_edge_dovetail_profile(
            coupler,
            clamp
        );
    else if (view == "access_section")
        hub75_lab_corner_edge_access_section(
            coupler,
            clamp,
            resolution = resolution
        );
    else if (view == "clamp_access")
        hub75_lab_corner_edge_clamp_access(
            coupler,
            clamp,
            resolution = resolution
        );
    else {
        hub75_lab_corner_edge_tube_mount(
            coupler,
            resolution = resolution
        );

        hub75_lab_corner_edge_clamp(
            coupler,
            clamp,
            z_shift_mm = clamp_z_shift_mm,
            resolution = resolution
        );

        if (show_tube)
            hub75_lab_corner_edge_tube(
                coupler,
                clamp,
                z_shift_mm = tube_z_shift_mm,
                resolution = resolution
            );
    }
}
