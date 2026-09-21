// HUB75 component-lab orientation and camera conventions.
//
// native orientation
//   Coordinate system owned by the source component/library.
//
// project orientation
//   Production/assembly coordinates used by the HUB75 parent project.
//
// design orientation
//   Lab working coordinates chosen for easy CAD inspection.
//   For the tube clamp the dovetail mounting/root plane lies parallel to XY,
//   with dovetail height along Z.
//
// print orientation
//   Physical slicer/print-bed orientation.
//
// Clamp mapping:
//   project X -> design X
//   project Y -> design -Z
//   project Z -> design Y
//
// This is a -90 degree rotation around project X.

module hub75_lab_design_orientation() {
    rotate([-90, 0, 0])
        children();
}

// Backward-compatible alias for older lab files.
module hub75_lab_development_orientation() {
    hub75_lab_design_orientation()
        children();
}

// Apply one named geometry orientation. Camera/view selection stays separate.
module hub75_lab_orientation(
    orientation = "design"
) {
    assert(
        orientation == "design"
            || orientation == "project"
            || orientation == "print",
        str("Unsupported lab orientation: ", orientation)
    )

    if (orientation == "design")
        hub75_lab_design_orientation()
            children();
    else if (orientation == "print")
        hub75_lab_print_orientation()
            children();
    else
        children();
}

// Print orientation for the detachable clamp/dovetail family.
//
// Project X (tube axis) becomes print +Z.
// Project Y remains print Y.
// Project Z becomes print -X.
module hub75_lab_print_orientation() {
    rotate([0, -90, 0])
        children();
}


// ----------------------------------------------------------------------
// Camera presets
// ----------------------------------------------------------------------

function hub75_lab_camera_rotation(view = "iso") =
    view == "front" ? [90, 0, 0]
        : view == "side" ? [90, 0, 90]
        : view == "top" ? [0, 0, 0]
        : [55, 0, 35];

function hub75_lab_camera_target(
    orientation = "design"
) =
    orientation == "project"
        ? [0, -8.5, 10]
        : orientation == "print"
            ? [-10, -8.5, 0]
            : [0, 10, 7.5];

function hub75_lab_camera_distance_single(
    orientation = "design"
) =
    orientation == "design" ? 78 : 82;

function hub75_lab_camera_distance_comparison(
    orientation = "design"
) =
    orientation == "design" ? 120 : 135;

// Backward-compatible camera aliases.
function hub75_lab_development_camera_target() =
    hub75_lab_camera_target("design");

function hub75_lab_development_camera_rotation() =
    hub75_lab_camera_rotation("iso");

function hub75_lab_development_camera_distance_single() =
    hub75_lab_camera_distance_single("design");

function hub75_lab_development_camera_distance_comparison() =
    hub75_lab_camera_distance_comparison("design");
