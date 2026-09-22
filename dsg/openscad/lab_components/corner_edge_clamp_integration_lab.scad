// File: corner_edge_clamp_integration_lab.scad
//   Isolated reproduction/inspection harness for parent HUB75 corner-edge
//   clamp integration. Production geometry is snapshotted from parent main
//   commit 267abce8a3ac6e65f493618d2d4cc03164ea9911.
//
// This file deliberately exposes construction/cutter states without changing
// the frozen baseline source.

use <../components/hub75/corner-edge-coupler/hub75_corner_edge_coupler.scad>
use <../project_components/tube_mount/corner-edge-coupler/hub75_tube_corner_edge_coupler.scad>
use <../project_components/tube_mount/tube-clamp/hub75_tube_clamp.scad>
use <../project_components/tube_mount/tube_mount_interface.scad>

/* [Corner lab] */
c_corner_state = "assembled"; // [core,tube_keepout,dovetail,insertion_keepout,tube_mount,assembled]
d_corner_side = "left"; // [left,right]
d_corner_size = "medium"; // [small,medium,large]
c_corner_show_clamp = true;
c_corner_show_tube = true;

/* [Inspection] */
c_corner_section = "none"; // [none,yz,xz]
d_corner_section_thickness_mm = 1.0;
c_corner_explode_mm = 0;

/* [Preview] */
c_corner_high_resolution = false;

function _corner_lab_coupler() =
    hub75_corner_edge_coupler_create_for_size(
        side = d_corner_side,
        size = d_corner_size
    );

function _corner_lab_clamp(coupler) =
    hub75_tube_clamp_create(
        dovetail = hub75_tube_mount_dovetail_create(
            host_depth_mm = coupler.base_thickness
        )
    );

module _corner_lab_tube(coupler, clamp) {
    clip_x = hub75_tube_corner_edge_clamp_x_mm(coupler);
    tube_d = hub75_tube_clamp_functional_diameter_mm(clamp);
    length_mm = coupler.profile_size + 2 * coupler.outside_projection + 20;

    color([0.72, 0.74, 0.76, 0.85])
        translate([
            clip_x - length_mm / 2,
            hub75_tube_clamp_tube_center_y_mm(clamp),
            hub75_tube_clamp_tube_center_z_mm(clamp)
        ])
            rotate([0, 90, 0])
                difference() {
                    cylinder(d = tube_d, h = length_mm);
                    translate([0, 0, -0.05])
                        cylinder(
                            d = max(0.1, tube_d - 2),
                            h = length_mm + 0.1
                        );
                }
}

module _corner_lab_core(coupler) {
    color([0.70, 0.70, 0.70, 1])
        hub75_corner_edge_coupler_build(coupler);
}

module _corner_lab_tube_keepout(coupler, clamp) {
    color([0.10, 0.45, 0.85, 0.70])
        _hub75_tube_corner_edge_keepout_cutter(coupler, clamp);
}

module _corner_lab_dovetail(coupler, clamp) {
    clip_x = hub75_tube_corner_edge_clamp_x_mm(coupler);

    color([0.90, 0.15, 0.08, 0.80])
        hub75_tube_mount_dovetail_female_cutter(
            clamp.dovetail,
            slide_len_mm = clamp.dovetail_slide_len_mm,
            center_x_mm = clip_x,
            center_z_mm = clamp.dovetail_center_z_mm
        );
}

module _corner_lab_insertion_keepout(coupler, clamp) {
    clip_x = hub75_tube_corner_edge_clamp_x_mm(coupler);

    color([0.90, 0.55, 0.05, 0.65])
        _hub75_tube_corner_edge_clamp_keepout_cutter(
            coupler,
            clamp,
            clip_x
        );
}

module _corner_lab_clamp(coupler, clamp, explode_mm = 0) {
    clip_x = hub75_tube_corner_edge_clamp_x_mm(coupler);

    translate([clip_x, 0, max(0, explode_mm)])
        hub75_tube_clamp_build(
            clamp,
            part_color = [0.92, 0.20, 0.08, 1],
            use_tension_bore = false,
            high_resolution = c_corner_high_resolution
        );
}

module _corner_lab_state(coupler, clamp) {
    if (c_corner_state == "core") {
        _corner_lab_core(coupler);
    } else if (c_corner_state == "tube_keepout") {
        _corner_lab_core(coupler);
        _corner_lab_tube_keepout(coupler, clamp);
    } else if (c_corner_state == "dovetail") {
        _corner_lab_core(coupler);
        _corner_lab_dovetail(coupler, clamp);
    } else if (c_corner_state == "insertion_keepout") {
        _corner_lab_core(coupler);
        _corner_lab_insertion_keepout(coupler, clamp);
    } else if (c_corner_state == "tube_mount") {
        color([0.72, 0.05, 0.04, 1])
            hub75_tube_corner_edge_coupler_build(coupler);
    } else {
        color([0.72, 0.05, 0.04, 1])
            hub75_tube_corner_edge_coupler_build(coupler);

        if (c_corner_show_clamp)
            _corner_lab_clamp(coupler, clamp, c_corner_explode_mm);

        if (c_corner_show_tube)
            _corner_lab_tube(coupler, clamp);
    }
}

module _corner_lab_section() {
    span = 240;
    t = max(0.1, d_corner_section_thickness_mm);

    if (c_corner_section == "yz")
        intersection() {
            children();
            cube([t, span, span], center = true);
        }
    else if (c_corner_section == "xz")
        intersection() {
            children();
            cube([span, t, span], center = true);
        }
    else
        children();
}

module corner_edge_clamp_integration_lab() {
    coupler = _corner_lab_coupler();
    clamp = _corner_lab_clamp(coupler);

    _corner_lab_section()
        _corner_lab_state(coupler, clamp);
}
