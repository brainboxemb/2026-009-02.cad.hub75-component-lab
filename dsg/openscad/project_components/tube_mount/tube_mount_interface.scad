// File: tube_mount_interface.scad
//   HUB75 adapter around the reusable lib.scad.mechint sliding dovetail.
//
// Project coordinates:
//   X = aluminium-tube axis;
//   Y = panel front -> rear, with the coupler mounting plane at Y = 0;
//   Z = local display-edge outward direction.
//
// lib.scad.mechint owns the profile, fit, entry slot and lock. HUB75 rotates
// that native interface so the clamp inserts from +Z. The Ø10 tube/clamp datum
// stays fixed with the tube front 1.0 mm behind the panel front face. The
// dovetail mouth is recessed another 0.5 mm into the clamp transition, at
// local Y = -2.0 mm. Small / medium / large hosts scale the dovetail height
// with their 2 / 3 / 4 mm rear-base thickness.

use <../../ext/lib.scad.mechint/openscad/sliding-dovetail/sliding_dovetail.scad>

_HUB75_TUBE_MOUNT_FRONT_OFFSET = 1.0;
_HUB75_TUBE_MOUNT_DOVETAIL_WIDTH = 12;
_HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_SMALL = 2.0;
_HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_MEDIUM = 2.5;
_HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_LARGE = 3.0;
_HUB75_TUBE_MOUNT_DOVETAIL_ANGLE = 30;
_HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_LAND_DEPTH = 0.5;
_HUB75_TUBE_MOUNT_DOVETAIL_ROOT_LAND_DEPTH = 0.5;
_HUB75_TUBE_MOUNT_DOVETAIL_CLEARANCE = 0.20;
_HUB75_TUBE_MOUNT_DOVETAIL_AXIAL_CLEARANCE = 0.25;
_HUB75_TUBE_MOUNT_DOVETAIL_ENTRY_SLOT_LENGTH = 16;
_HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y = -2.0;
_HUB75_TUBE_MOUNT_LOCK_MIN_SPRING_THICKNESS = 0.8;
_HUB75_TUBE_MOUNT_LOCK_HINGE_THICKNESS = 0.8;
_HUB75_TUBE_MOUNT_LOCK_HINGE_LENGTH_FACTOR = 0.5;

function hub75_tube_mount_tube_front_offset() =
    _HUB75_TUBE_MOUNT_FRONT_OFFSET;

// Lab isolation datum copied from parent PR #45.
_LAB_PANEL_MOUNTING_PLANE_Y = 14.5;

function hub75_tube_mount_tube_center_y(
    tube_diameter = 10,
    panel = undef
) =
    hub75_tube_mount_tube_front_offset()
    + tube_diameter / 2
    - _LAB_PANEL_MOUNTING_PLANE_Y;

function hub75_tube_mount_dovetail_mouth_y() =
    _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y;

function hub75_tube_mount_host_depth_for_size(size) =
    assert(
        size == "small" || size == "medium" || size == "large",
        str("Unsupported tube-mount size: ", size)
    )
    size == "small" ? 2
        : size == "large" ? 4
        : 3;

function hub75_tube_mount_dovetail_height_for_size(size) =
    assert(
        size == "small" || size == "medium" || size == "large",
        str("Unsupported tube-mount size: ", size)
    )
    size == "small"
        ? _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_SMALL
        : size == "large"
            ? _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_LARGE
            : _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_MEDIUM;

function hub75_tube_mount_dovetail_height_for_host_depth(host_depth) =
    assert(host_depth > 0, "tube-mount host_depth must be > 0")
    1 + host_depth / 2;

function hub75_tube_mount_dovetail_channel_roof_y(dovetail_height) =
    _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y
    + dovetail_height
    + _HUB75_TUBE_MOUNT_DOVETAIL_CLEARANCE;

function hub75_tube_mount_dovetail_min_host_depth(
    dovetail_height = _HUB75_TUBE_MOUNT_DOVETAIL_HEIGHT_SMALL
) =
    hub75_tube_mount_dovetail_channel_roof_y(dovetail_height)
    + _HUB75_TUBE_MOUNT_LOCK_MIN_SPRING_THICKNESS;

function hub75_tube_mount_lock_spring_thickness(
    host_depth,
    dovetail_height
) =
    host_depth
    - hub75_tube_mount_dovetail_channel_roof_y(dovetail_height);

function hub75_tube_mount_dovetail_create(
    host_depth = 3,
    dovetail_height = undef,
    entry_slot_length = _HUB75_TUBE_MOUNT_DOVETAIL_ENTRY_SLOT_LENGTH,
    lock_spring_transverse_relief_shape = "rectangular",
    lock_spring_transverse_relief_angle = 45
) =
    let(
        active_dovetail_height =
            is_undef(dovetail_height)
                ? hub75_tube_mount_dovetail_height_for_host_depth(host_depth)
                : dovetail_height,
        spring_thickness =
            hub75_tube_mount_lock_spring_thickness(
                host_depth,
                active_dovetail_height
            ),
        hinge_length =
            spring_thickness > _HUB75_TUBE_MOUNT_LOCK_HINGE_THICKNESS
                ? spring_thickness
                    * _HUB75_TUBE_MOUNT_LOCK_HINGE_LENGTH_FACTOR
                : 0
    )
    assert(
        spring_thickness >= _HUB75_TUBE_MOUNT_LOCK_MIN_SPRING_THICKNESS,
        "tube-mount dovetail host leaves too little material for the lock tongue"
    )
    sliding_dovetail_create(
        width = _HUB75_TUBE_MOUNT_DOVETAIL_WIDTH,
        height = active_dovetail_height,
        angle = _HUB75_TUBE_MOUNT_DOVETAIL_ANGLE,
        root_land_depth =
            _HUB75_TUBE_MOUNT_DOVETAIL_ROOT_LAND_DEPTH,
        mouth_land_depth =
            _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_LAND_DEPTH,
        clearance = _HUB75_TUBE_MOUNT_DOVETAIL_CLEARANCE,
        axial_clearance = _HUB75_TUBE_MOUNT_DOVETAIL_AXIAL_CLEARANCE,
        entry_slot_length = entry_slot_length,
        locking = true,
        lock_spring_thickness = spring_thickness,
        lock_spring_hinge_length = hinge_length,
        lock_spring_hinge_thickness =
            _HUB75_TUBE_MOUNT_LOCK_HINGE_THICKNESS,
        lock_spring_transverse_relief_shape =
            lock_spring_transverse_relief_shape,
        lock_spring_transverse_relief_angle =
            lock_spring_transverse_relief_angle,
        lock_cut_back_clearance = false,
        lock_back_clearance = 0
    );

function hub75_tube_mount_dovetail_create_for_size(
    size,
    entry_slot_length = _HUB75_TUBE_MOUNT_DOVETAIL_ENTRY_SLOT_LENGTH,
    lock_spring_transverse_relief_shape = "rectangular",
    lock_spring_transverse_relief_angle = 45
) =
    hub75_tube_mount_dovetail_create(
        host_depth = hub75_tube_mount_host_depth_for_size(size),
        dovetail_height = hub75_tube_mount_dovetail_height_for_size(size),
        entry_slot_length = entry_slot_length,
        lock_spring_transverse_relief_shape =
            lock_spring_transverse_relief_shape,
        lock_spring_transverse_relief_angle =
            lock_spring_transverse_relief_angle
    );

function hub75_tube_mount_dovetail_angle(dovetail) =
    dovetail.angle;

function hub75_tube_mount_dovetail_mouth_land_depth(dovetail) =
    sliding_dovetail_mouth_land_depth(dovetail);

function hub75_tube_mount_dovetail_root_land_depth(dovetail) =
    sliding_dovetail_root_land_depth(dovetail);

function hub75_tube_mount_dovetail_mouth_width(dovetail) =
    sliding_dovetail_mouth_width(dovetail);

function hub75_tube_mount_dovetail_female_root_width(dovetail) =
    sliding_dovetail_female_root_width(dovetail);

function hub75_tube_mount_dovetail_female_slide(
    dovetail,
    slide
) =
    sliding_dovetail_female_slide(
        dovetail,
        slide
    );

function hub75_tube_mount_dovetail_entry_slot_length(dovetail) =
    sliding_dovetail_entry_slot_length(dovetail);


// ----------------------------------------------------------------------
// Public geometry API
// ----------------------------------------------------------------------

module hub75_tube_mount_dovetail_male_build(
    dovetail,
    slide,
    center_x = 0,
    center_z = 0
) {
    _hub75_tube_mount_dovetail_to_project(
        center_x = center_x,
        center_z = center_z
    )
        sliding_dovetail_male_build(
            dovetail,
            slide = slide
        );
}

module hub75_tube_mount_dovetail_male_relief_cutter(
    dovetail,
    slide,
    relief_width,
    center_x = 0,
    center_z = 0
) {
    _hub75_tube_mount_dovetail_to_project(
        center_x = center_x,
        center_z = center_z
    )
        sliding_dovetail_male_relief_cutter(
            dovetail,
            slide = slide,
            relief_width = relief_width
        );
}

module hub75_tube_mount_dovetail_female_cutter(
    dovetail,
    slide,
    center_x = 0,
    center_z = 0
) {
    _hub75_tube_mount_dovetail_to_project(
        center_x = center_x,
        center_z = center_z
    )
        sliding_dovetail_female_cutter(
            dovetail,
            slide = slide
        );
}


// ----------------------------------------------------------------------
// Private coordinate transform
// ----------------------------------------------------------------------

module _hub75_tube_mount_dovetail_to_project(
    center_x = 0,
    center_z = 0
) {
    // Native X becomes project -Z, native Y remains project Y with its mouth
    // at -1.5 mm, and native Z becomes project X.
    multmatrix([
        [ 0, 0, 1, center_x],
        [ 0, 1, 0, _HUB75_TUBE_MOUNT_DOVETAIL_MOUTH_Y],
        [-1, 0, 0, center_z],
        [ 0, 0, 0, 1]
    ])
        children();
}
