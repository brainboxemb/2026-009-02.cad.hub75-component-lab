// File: hub75_panel_mating.scad
//   Shared project-side mating helpers for the current HUB75 coupler family.
//
// The reusable lib.scad.hub75 model remains the authority for the physical
// taper depth and rear inset. This file only converts those authoritative
// values into the displacement at a requested insertion depth measured
// forward from the rear mounting plane.

// Function: hub75_panel_taper_shift_at_depth_mm()
// Description:
//   Returns how far an external HUB75 panel wall has moved outward from its
//   rear-mounting-plane position at depth_mm forward into the panel.
//
// The production panel model uses one continuous linear outer-wall taper. The
// shift is therefore linear until the front of that taper and is clamped there
// for any deeper caller request.
function hub75_panel_taper_shift_at_depth_mm(
    depth_mm,
    taper_depth_mm,
    rear_inset_mm
) =
    rear_inset_mm
    * min(
        max(depth_mm, 0),
        max(taper_depth_mm, 0.01)
    )
    / max(taper_depth_mm, 0.01);
