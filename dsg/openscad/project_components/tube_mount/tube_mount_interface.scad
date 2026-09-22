// File: tube_mount_interface.scad
//   HUB75 adapter around the reusable lib.scad.mechint sliding dovetail.
//
// Project orientation:
//   X = aluminium-tube axis;
//   Y = panel front -> rear, with the coupler mounting plane at Y = 0;
//   Z = local display-edge outward direction.
//
// lib.scad.mechint design orientation:
//   X = slide / insertion direction;
//   Y = profile depth, mouth at Y = 0 and root toward +Y;
//   Z = profile width.
//
// HUB75 maps that design orientation into the project orientation so the clamp
// inserts from +Z. The Ø10 tube/clamp datum stays fixed with the tube front
// 1.0 mm behind the panel front face. The dovetail mouth is recessed another
// 0.5 mm into the clamp transition, at project Y = -2.0 mm. Small / medium /
// large hosts scale the dovetail height with their 2 / 3 / 4 mm rear-base
// thickness.

use <../../ext/lib.scad.mechint/openscad/sliding_dovetail.scad>
use <../../ext/lib.scad.hub75/openscad/p5-64x32-panel/hub75_p5_64x32_panel.scad>
use <../../ext/lib.scad.forge/openscad/transform.scad>

_HUB75_TUBE_MOUNT_FRONT_OFFSET_MM = 1.0;
_HUB75_TUBE_MOUNT_DOVETAIL_WIDTH_MM = 12;
_HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_SMALL_MM = 2.0;
_HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_MEDIUM_MM = 2.5;
_HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_LARGE_MM = 3.0;
_HUB75_TUBE_MOUNT_DOVETAIL_ANGLE_DEG = 30;
_HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_LAND_DEPTH_MM = 0.5;
_HUB75_TUBE_MOUNT_DOVETAIL_ROOT_LAND_DEPTH_MM = 0.5;
_HUB75_TUBE_MOUNT_DOVETAIL_CLEARANCE_MM = 0.20;
_HUB75_TUBE_MOUNT_DOVETAIL_AXIAL_CLEARANCE_MM = 0.25;
_HUB75_TUBE_MOUNT_DOVETAIL_ENTRY_SLOT_LEN_MM = 16;
_HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y_MM = -2.0;
_HUB75_TUBE_MOUNT_LOCK_MIN_SPRING_THICKNESS_MM = 0.8;
_HUB75_TUBE_MOUNT_LOCK_HINGE_THICKNESS_MM = 0.8;
_HUB75_TUBE_MOUNT_LOCK_HINGE_LENGTH_FACTOR = 0.5;
_HUB75_TUBE_MOUNT_LOCK_RELEASE_SHAPE = "trapezoid";
_HUB75_TUBE_MOUNT_LOCK_RELEASE_TAPER_ANGLE_DEG = 45;

function hub75_tube_mount_tube_front_offset_mm() =
    _HUB75_TUBE_MOUNT_FRONT_OFFSET_MM;

function hub75_tube_mount_tube_center_y_mm(
    tube_diameter_mm = 10,
    panel = hub75_p5_64x32_panel_create()
) =
    hub75_tube_mount_tube_front_offset_mm()
    + tube_diameter_mm / 2
    - hub75_p5_64x32_panel_mounting_plane_y(panel);

function hub75_tube_mount_dovetail_mouth_y_mm() =
    _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y_MM;

function hub75_tube_mount_host_depth_mm_for_size(size) =
    assert(
        size == "small" || size == "medium" || size == "large",
        str("Unsupported tube-mount size: ", size)
    )
    size == "small" ? 2
        : size == "large" ? 4
        : 3;

function hub75_tube_mount_dovetail_height_mm_for_size(size) =
    assert(
        size == "small" || size == "medium" || size == "large",
        str("Unsupported tube-mount size: ", size)
    )
    size == "small"
        ? _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_SMALL_MM
        : size == "large"
            ? _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_LARGE_MM
            : _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_MEDIUM_MM;

function hub75_tube_mount_dovetail_height_mm_for_host_depth(
    host_depth_mm
) =
    assert(host_depth_mm > 0, "tube-mount host_depth_mm must be > 0")
    1 + host_depth_mm / 2;

function hub75_tube_mount_dovetail_channel_roof_y_mm(
    dovetail_height_mm
) =
    _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y_MM
    + dovetail_height_mm
    + _HUB75_TUBE_MOUNT_DOVETAIL_CLEARANCE_MM;

function hub75_tube_mount_dovetail_min_host_depth_mm(
    dovetail_height_mm = _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_SMALL_MM
) =
    hub75_tube_mount_dovetail_channel_roof_y_mm(dovetail_height_mm)
    + _HUB75_TUBE_MOUNT_LOCK_MIN_SPRING_THICKNESS_MM;

function hub75_tube_mount_lock_spring_thickness_mm(
    host_depth_mm,
    dovetail_height_mm
) =
    host_depth_mm
    - hub75_tube_mount_dovetail_channel_roof_y_mm(dovetail_height_mm);

function hub75_tube_mount_dovetail_create(
    host_depth_mm = 3,
    dovetail_height_mm = undef,
    entry_slot_len_mm = _HUB75_TUBE_MOUNT_DOVETAIL_ENTRY_SLOT_LEN_MM
) =
    let(
        _active_dovetail_height_mm =
            is_undef(dovetail_height_mm)
                ? hub75_tube_mount_dovetail_height_mm_for_host_depth(
                    host_depth_mm
                )
                : dovetail_height_mm,
        _spring_thickness_mm =
            hub75_tube_mount_lock_spring_thickness_mm(
                host_depth_mm,
                _active_dovetail_height_mm
            ),
        _hinge_len_mm =
            _spring_thickness_mm
                > _HUB75_TUBE_MOUNT_LOCK_HINGE_THICKNESS_MM
                ? _spring_thickness_mm
                    * _HUB75_TUBE_MOUNT_LOCK_HINGE_LENGTH_FACTOR
                : 0
    )
    assert(
        _spring_thickness_mm
            >= _HUB75_TUBE_MOUNT_LOCK_MIN_SPRING_THICKNESS_MM,
        "tube-mount dovetail host leaves too little material for the lock tongue"
    )
    sliding_dovetail_create(
        width_mm = _HUB75_TUBE_MOUNT_DOVETAIL_WIDTH_MM,
        height_mm = _active_dovetail_height_mm,
        angle_deg = _HUB75_TUBE_MOUNT_DOVETAIL_ANGLE_DEG,
        root_land_depth_mm =
            _HUB75_TUBE_MOUNT_DOVETAIL_ROOT_LAND_DEPTH_MM,
        mouth_land_depth_mm =
            _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_LAND_DEPTH_MM,
        clearance_mm = _HUB75_TUBE_MOUNT_DOVETAIL_CLEARANCE_MM,
        axial_clearance_mm =
            _HUB75_TUBE_MOUNT_DOVETAIL_AXIAL_CLEARANCE_MM,
        entry_slot_len_mm = entry_slot_len_mm,
        is_locking_enabled = true,
        lock_spring_thickness_mm = _spring_thickness_mm,
        lock_spring_hinge_len_mm = _hinge_len_mm,
        lock_spring_hinge_thickness_mm =
            _HUB75_TUBE_MOUNT_LOCK_HINGE_THICKNESS_MM,
        lock_release_shape =
            _HUB75_TUBE_MOUNT_LOCK_RELEASE_SHAPE,
        lock_release_taper_angle_deg =
            _HUB75_TUBE_MOUNT_LOCK_RELEASE_TAPER_ANGLE_DEG,
        lock_has_back_clearance = false,
        lock_back_clearance_mm = 0
    );

function hub75_tube_mount_dovetail_create_for_size(
    size,
    entry_slot_len_mm = _HUB75_TUBE_MOUNT_DOVETAIL_ENTRY_SLOT_LEN_MM
) =
    hub75_tube_mount_dovetail_create(
        host_depth_mm = hub75_tube_mount_host_depth_mm_for_size(size),
        dovetail_height_mm =
            hub75_tube_mount_dovetail_height_mm_for_size(size),
        entry_slot_len_mm = entry_slot_len_mm
    );

function hub75_tube_mount_dovetail_angle_deg(obj) =
    obj.angle_deg;

function hub75_tube_mount_dovetail_mouth_land_depth_mm(obj) =
    sliding_dovetail_mouth_land_depth_mm(obj);

function hub75_tube_mount_dovetail_root_land_depth_mm(obj) =
    sliding_dovetail_root_land_depth_mm(obj);

function hub75_tube_mount_dovetail_mouth_width_mm(obj) =
    sliding_dovetail_mouth_width_mm(obj);

function hub75_tube_mount_dovetail_female_root_width_mm(obj) =
    sliding_dovetail_female_root_width_mm(obj);

function hub75_tube_mount_dovetail_female_slide_len_mm(
    obj,
    slide_len_mm
) =
    sliding_dovetail_female_slide_len_mm(
        obj,
        slide_len_mm
    );

function hub75_tube_mount_dovetail_entry_slot_len_mm(obj) =
    sliding_dovetail_entry_slot_len_mm(obj);


// ----------------------------------------------------------------------
// Public geometry API
// ----------------------------------------------------------------------

module hub75_tube_mount_dovetail_male_build(
    obj,
    slide_len_mm,
    center_x_mm = 0,
    center_z_mm = 0
) {
    _hub75_tube_mount_dovetail_to_project(
        center_x_mm = center_x_mm,
        center_z_mm = center_z_mm
    )
        sliding_dovetail_male_build(
            obj,
            slide_len_mm = slide_len_mm
        );
}

module hub75_tube_mount_dovetail_male_relief_cutter(
    obj,
    slide_len_mm,
    relief_width_mm,
    center_x_mm = 0,
    center_z_mm = 0
) {
    _hub75_tube_mount_dovetail_to_project(
        center_x_mm = center_x_mm,
        center_z_mm = center_z_mm
    )
        sliding_dovetail_male_relief_cutter(
            obj,
            slide_len_mm = slide_len_mm,
            relief_width_mm = relief_width_mm
        );
}

module hub75_tube_mount_dovetail_female_cutter(
    obj,
    slide_len_mm,
    center_x_mm = 0,
    center_z_mm = 0
) {
    _hub75_tube_mount_dovetail_to_project(
        center_x_mm = center_x_mm,
        center_z_mm = center_z_mm
    )
        sliding_dovetail_female_cutter(
            obj,
            slide_len_mm = slide_len_mm
        );
}


// ----------------------------------------------------------------------
// Private coordinate transform
// ----------------------------------------------------------------------

module _hub75_tube_mount_dovetail_to_project(
    center_x_mm = 0,
    center_z_mm = 0
) {
    // Mechint design X -> project -Z.
    // Mechint design Y -> project +Y.
    // The right-handed frame derives design Z -> project +X.
    fg_xf_frame(
        pos_mm = [
            center_x_mm,
            _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y_MM,
            center_z_mm
        ],
        x_axis = [0, 0, -1],
        y_axis = [0, 1, 0]
    )
        children();
}
