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
//   project Y -> development Z
//   project Z -> development -Y
//
// This is a +90 degree rotation around project X.

module hub75_lab_development_orientation() {
    rotate([90, 0, 0])
        children();
}
