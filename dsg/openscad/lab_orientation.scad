// HUB75 component-lab orientation conventions.
//
// native orientation
//   Coordinate system owned by the source component/library.
//
// project orientation
//   Production/assembly coordinates used by the HUB75 parent project.
//
// development orientation
//   Lab working coordinates chosen for easy CAD inspection.
//   For the tube clamp the dovetail mounting/root plane lies parallel to XY,
//   with dovetail height along Z.
//
// print orientation
//   Physical slicer/print-bed orientation. This is intentionally a separate
//   concept and is not implied by the development orientation.
//
// Current clamp conversion:
//   project X -> development X
//   project Y -> development -Z
//   project Z -> development Y
//
// This is a -90 degree rotation around project X.  It keeps the dovetail
// mounting/root plane parallel to XY with the clamp body above that plane.

module hub75_lab_development_orientation() {
    rotate([-90, 0, 0])
        children();
}


// Standard development camera.  Keep camera semantics separate from geometry
// orientation: changing a view must not change the model coordinate system.
function hub75_lab_development_camera_target() = [0, 10, 7.5];
function hub75_lab_development_camera_rotation() = [55, 0, 35];
function hub75_lab_development_camera_distance_single() = 78;
function hub75_lab_development_camera_distance_comparison() = 120;

// Print orientation for the detachable clamp / dovetail family.
//
// Project X (tube axis) becomes print +Z, matching the intended side print.
// Project Y remains print Y; project Z becomes print -X.
module hub75_lab_print_orientation() {
    rotate([0, -90, 0])
        children();
}
