// File: hub75_tube_corner_edge_coupler.scad
//   Tube-aware corner-edge coupler using the same top-entry clamp interface as
//   the horizontal-edge tube coupler.
//
// The accepted corner-edge exterior remains unchanged. Tube clearance, local
// clamp clearance and the female dovetail are cut directly from the existing
// corner geometry. The clamp/interface X datum is the existing vertical
// side-rail centre, because that is the corner mass that reaches the tube height.

use <../../../components/hub75/corner-edge-coupler/hub75_corner_edge_coupler.scad>
use <../../../ext/lib.scad.forge/openscad/resolution.scad>
use <../../../ext/lib.scad.forge/openscad/transform.scad>
use <../../../ext/lib.scad.forge/openscad/cutter.scad>
use <../../../ext/lib.scad.forge/openscad/csg.scad>
use <../tube-clamp/hub75_tube_clamp.scad>
use <../tube_mount_interface.scad>

_HUB75_TUBE_CORNER_EPS_MM = 0.05;

function hub75_tube_corner_edge_clamp_x_mm(coupler_obj) =
    hub75_corner_edge_coupler_side_rail_center_x(coupler_obj);

function hub75_tube_corner_edge_available_interface_width_mm(coupler_obj) =
    hub75_corner_edge_coupler_vertical_arm_width(coupler_obj);

function hub75_tube_corner_edge_required_interface_width_mm(
    coupler_obj,
    clamp_obj = hub75_tube_clamp_create()
) =
    max(
        hub75_tube_mount_dovetail_female_root_width_mm(
            clamp_obj.dovetail
        ),
        clamp_obj.base_clamp.clamp_width
            + 2 * hub75_tube_corner_edge_clamp_body_clearance_mm(coupler_obj)
    );

function hub75_tube_corner_edge_keepout_radial_clearance_mm(coupler_obj) =
    coupler_obj.fit_clearance;

function hub75_tube_corner_edge_clamp_body_clearance_mm(coupler_obj) =
    coupler_obj.fit_clearance;


// ----------------------------------------------------------------------
// Public geometry
// ----------------------------------------------------------------------

module hub75_tube_corner_edge_coupler_build(
    coupler_obj,
    resolution = FG_RES_HIGH()
) {
    fg_res_apply(resolution) {
        clamp_obj =
            hub75_tube_clamp_create(
                dovetail_obj =
                    hub75_tube_mount_dovetail_create(
                        host_depth_mm = coupler_obj.base_thickness
                    )
            );
        clip_x = hub75_tube_corner_edge_clamp_x_mm(coupler_obj);
        available_interface_width =
            hub75_tube_corner_edge_available_interface_width_mm(coupler_obj);
        required_interface_width =
            hub75_tube_corner_edge_required_interface_width_mm(
                coupler_obj,
                clamp_obj
            );

        assert(
            required_interface_width <= available_interface_width,
            "corner tube-mount interface does not fit inside the existing vertical arm"
        );

        fg_diff() {
            fg_body()
                hub75_corner_edge_coupler_build(coupler_obj);

            fg_remove() {
                _hub75_tube_corner_edge_keepout_cutter(
                    coupler_obj,
                    clamp_obj
                );

                _hub75_tube_corner_edge_clamp_keepout_cutter(
                    coupler_obj,
                    clamp_obj,
                    clip_x
                );

                hub75_tube_mount_dovetail_female_cutter(
                    clamp_obj.dovetail,
                    slide_len_mm = clamp_obj.dovetail_slide_len_mm,
                    center_x_mm = clip_x,
                    center_z_mm = clamp_obj.dovetail_center_z_mm
                );
            }
        }
    }
}


// ----------------------------------------------------------------------
// Private implementation
// ----------------------------------------------------------------------

module _hub75_tube_corner_edge_keepout_cutter(
    coupler_obj,
    clamp_obj
) {
    keepout_d =
        hub75_tube_clamp_functional_diameter_mm(clamp_obj)
        + 2 * hub75_tube_corner_edge_keepout_radial_clearance_mm(coupler_obj);
    cutter_length =
        coupler_obj.profile_size
        + 2 * coupler_obj.outside_projection;

    fg_cut_cylinder(
        diameter_mm = keepout_d,
        height_mm = cutter_length,
        pos_mm = [
            -cutter_length / 2,
            hub75_tube_clamp_tube_center_y_mm(clamp_obj),
            hub75_tube_clamp_tube_center_z_mm(clamp_obj)
        ],
        rot_deg = [0, 90, 0],
        overlap = [FG_BOTTOM(), FG_TOP()],
        overlap_mm = _HUB75_TUBE_CORNER_EPS_MM
    );
}


module _hub75_tube_corner_edge_outer_ring_envelope(
    clamp_obj,
    clip_x,
    radial_clearance = 0,
    lateral_clearance = 0,
    z_shift = 0
) {
    ring_r =
        hub75_tube_clamp_outer_diameter_mm(clamp_obj) / 2
        + radial_clearance;
    ring_width =
        clamp_obj.base_clamp.clamp_width
        + 2 * lateral_clearance;

    fg_xf_frame(
        pos_mm = [
            clip_x - ring_width / 2,
            hub75_tube_clamp_tube_center_y_mm(clamp_obj),
            hub75_tube_clamp_tube_center_z_mm(clamp_obj) + z_shift
        ],
        y_axis = [0, 1, 0],
        z_axis = [1, 0, 0]
    )
        cylinder(
            r = ring_r,
            h = ring_width
        );
}


module _hub75_tube_corner_edge_clamp_access_cutter(
    coupler_obj,
    clamp_obj,
    clip_x,
    clearance,
    entry_travel
) {
    ring_r =
        hub75_tube_clamp_outer_diameter_mm(clamp_obj) / 2
        + clearance;
    ring_front_y =
        hub75_tube_clamp_tube_center_y_mm(clamp_obj)
        + ring_r;
    rear_y =
        coupler_obj.base_thickness
        + _HUB75_TUBE_CORNER_EPS_MM;
    access_depth =
        rear_y - ring_front_y;
    z_bottom =
        hub75_tube_clamp_tube_center_z_mm(clamp_obj)
        - ring_r;
    z_top =
        max(
            coupler_obj.outside_projection
                + _HUB75_TUBE_CORNER_EPS_MM,
            hub75_tube_clamp_tube_center_z_mm(clamp_obj)
                + entry_travel
                + ring_r
        );
    opening_width =
        clamp_obj.base_clamp.clamp_width
        + 2 * clearance;

    assert(
        access_depth > 0,
        "corner clamp access opening must reach the rear print face"
    );

    // Open the swept circular clamp cavity all the way to the rear print face.
    // The lower edge rises at 45 degrees from the rear face to the circular
    // envelope, removing the thin plate/shelf that previously sat underneath
    // the clip.  With rear-face-down printing this avoids the unsupported
    // circular roof while keeping the cavity simple and inspectable.
    fg_xf_frame(
        pos_mm = [clip_x - opening_width / 2, 0, 0],
        x_axis = [0, 1, 0],
        y_axis = [0, 0, 1]
    )
        linear_extrude(height = opening_width)
            polygon(points = [
                [
                    ring_front_y - _HUB75_TUBE_CORNER_EPS_MM,
                    z_bottom
                ],
                [
                    ring_front_y - _HUB75_TUBE_CORNER_EPS_MM,
                    z_top
                ],
                [
                    rear_y,
                    z_top
                ],
                [
                    rear_y,
                    z_bottom - access_depth
                ]
            ]);
}


module _hub75_tube_corner_edge_clamp_keepout_cutter(
    coupler_obj,
    clamp_obj,
    clip_x
) {
    clearance =
        hub75_tube_corner_edge_clamp_body_clearance_mm(coupler_obj);
    entry_travel =
        hub75_tube_mount_dovetail_entry_slot_len_mm(
            clamp_obj.dovetail
        );

    assert(
        entry_travel > 0,
        "corner clamp keepout needs positive dovetail entry travel"
    );

    // Keep the exact swept circular envelope for the clip itself, then connect
    // it to the rear print face with a simple 45-degree access opening.  The
    // male dovetail still owns its own exact female cutter.  Filling the ring
    // deliberately clears the snap opening and bore as well: those voids belong
    // to the detachable clamp and must not be occupied by corner material
    // anywhere along the +Z insertion path.
    assert(
        clamp_obj.base_clamp.transition_width
            <= hub75_tube_clamp_outer_diameter_mm(clamp_obj)
                + 2 * clearance,
        "corner ring envelope no longer contains the clamp transition"
    );

    union() {
        hull() {
            _hub75_tube_corner_edge_outer_ring_envelope(
                clamp_obj,
                clip_x,
                radial_clearance = clearance,
                lateral_clearance = clearance,
                z_shift = 0
            );

            _hub75_tube_corner_edge_outer_ring_envelope(
                clamp_obj,
                clip_x,
                radial_clearance = clearance,
                lateral_clearance = clearance,
                z_shift = entry_travel
            );
        }

        _hub75_tube_corner_edge_clamp_access_cutter(
            coupler_obj,
            clamp_obj,
            clip_x,
            clearance,
            entry_travel
        );
    }
}
