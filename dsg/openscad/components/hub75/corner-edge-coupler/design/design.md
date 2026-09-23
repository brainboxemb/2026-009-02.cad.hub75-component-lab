# HUB75 corner-edge coupler — design

<!-- scad-render-defaults
engine: openscad
source: hub75_corner_edge_coupler_render.scad
module: hub75_corner_edge_coupler_design
vpr: [68, 0, 35]
vpt: [10, 0, -10]
vpd: 210
-->

## Purpose of this document

This document explains **how the corner-edge coupler is constructed
geometrically**. It follows the same four-layer rule as the middle and
horizontal-edge documents:

```text
physical feature or constraint
    ↓
geometric construction or change
    ↓
image that makes that change visible
    ↓
production helper/module that implements it
```

The explanatory images may use intermediate primitives that do not exist as
separate production modules. When that happens the text identifies the view as
documentation-only and points to the production helper that generates the
corresponding final geometry.

## Physical purpose and variants

The corner-edge coupler supports one outside corner of a portrait HUB75 panel.
Only two printable variants are required:

```text
left
    top-left
    rotate 180 degrees -> bottom-right

right
    top-right
    rotate 180 degrees -> bottom-left
```

The difference matters because the panel locating pins are diagonal: the
physical top-left/bottom-right pair contains a locator pin in this interface,
while the top-right/bottom-left pair does not.

The first implementation deliberately contains no aluminium-tube clip. The
corner body and panel fit are established first.

## Coordinate system

The nominal panel corner, not the screw, is the component datum:

```text
X = 0
Z = 0
    nominal 160 × 320 mm panel corner

Y = 0
    HUB75 rear mounting plane
```

For the left part +X points inward across the panel. For the right part -X points
inward. For both top variants -Z points inward.

The physical rear rails lie slightly inward from the nominal envelope, so the
printed arms are intentionally offset from the `+` datum.

## Construction overview

```text
A. construct the asymmetric corner body
   physical side rail + end rail
       ↓
   horizontal arm around end rail
       ↓
   vertical arm around side rail
       ↓
   raw asymmetric cross
       ↓
   rounded asymmetric profile
       ↓
   reinforcement support envelope where required
       ↓
   extrude base

B. fit panel hardware
   corner screw bore
       ↓
   mounting-tube pocket
       ↓
   conditional locator-pin clearance

C. construct corner guides
   real physical corner keep-out
       ↓
   raw guide shell
       ↓
   end-mask / free-end rounding
       ↓
   split inward guide / two outside ridges
       ↓
   panel-derived X/Z taper on the two outside ridges
       ↓
   reinforcement support + relief
       ↓
   complete guide system
       ↓
   reinforcement pad/pin locator

D. finish the visible surface
   functional corner
       ↓
   blind reference pockets
       ↓
   nominal-corner + and distance ticks
       ↓
   complete left/right part
```

## Family dimensions

```text
small    profile  60 mm   wall 2 mm   guide  4 mm   base 2 mm
medium   profile  80 mm   wall 4 mm   guide  6 mm   base 3 mm
large    profile 100 mm   wall 6 mm   guide 10 mm   base 4 mm
```

The inward arm reach is half the selected profile size. The two outside reaches
are deliberately fixed at `19.5 mm`, below the project-wide 20 mm projection
limit.

## 1. Establish the physical rear-corner reference

The printable corner must fit around the actual rear material, not around the
nominal panel envelope.

At the corner the real panel presents:

```text
one rear side rail
one rear end rail
one rounded opening transition between them
```

The gray region is the physical panel keep-out near the printable corner. Red is
the same keep-out expanded by `fit_clearance`.

<!-- scad-render
view: mating-reference
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

The production representation is:

```scad
_hub75_corner_edge_coupler_panel_keepout_2d(coupler)
```

It starts from the physical rear panel quadrant and subtracts the rounded rear
opening. The side/end rail widths and opening radius are all panel-derived.

## 2. Build the horizontal arm around the rear end rail

The horizontal arm follows the real rear end rail centre, not nominal Z=0.

Its printable height is:

```text
rear end rail width
+ fit clearance on both sides
+ printed wall on both sides
```

or:

```scad
coupler.rear_end_rail_width
+ 2 * (coupler.wall_thickness + coupler.fit_clearance)
```

The gray strip is the physical end rail; the red strip is the printable arm.

<!-- scad-render
view: profile-horizontal-arm
vpr: [0, 0, 0]
vpt: [8, 0, -5]
-->

Production exposes the height and centre as:

```scad
hub75_corner_edge_coupler_horizontal_arm_height(coupler)
hub75_corner_edge_coupler_end_rail_center_z(coupler)
```

The arm spans the complete selected corner range: inward reach on one side and
`outside_projection` on the other.

## 3. Build the vertical arm around the rear side rail

The second arm follows the real side-rail centre.

Its width is:

```text
rear side rail width
+ fit clearance on both sides
+ printed wall on both sides
```

The gray geometry is the already established horizontal arm. Red is the newly
added vertical arm.

<!-- scad-render
view: profile-vertical-arm
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

The production accessors are:

```scad
hub75_corner_edge_coupler_vertical_arm_width(coupler)
hub75_corner_edge_coupler_side_rail_center_x(coupler)
```

This rectangle is a documentation-only primitive. Production uses the same
derived dimensions directly inside the final profile polygon.

## 4. Form the raw asymmetric cross

The simplest conceptual corner shape is:

```text
horizontal rail arm
UNION
vertical rail arm
=
raw asymmetric cross
```

Its bounds are intentionally unequal:

```text
inward X/Z reach     profile_size / 2
outside X/Z reach    19.5 mm
```

<!-- scad-render
view: profile-raw-cross
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

There is no dedicated production module for this sharp-edged state. It exists
only to make the next rounding step understandable. The production profile uses
these same bounds in:

```scad
_hub75_corner_edge_coupler_profile_2d(coupler)
```

## 5. Round the asymmetric profile

The family radii are then applied conceptually:

```text
concave rail-arm transitions    R10
convex free arm ends             R6
```

Gray is the raw cross from step 4. Red is the final rounded profile.

<!-- scad-render
view: profile-rounded
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

Production does not round a Boolean union. It directly generates one polygon
with explicit straight runs and quarter-circle transitions:

```scad
_hub75_corner_edge_coupler_profile_2d(coupler)
```

That module also accepts `outside_radius_override`; the guide construction later
uses that controlled variant as an end mask without changing the production
base profile.

## 6. Preserve structural material and extrude the base plate

The physical corner reinforcement keeps the same diameter for every family
preset. On the 2 mm small profile, subtracting its required clearance from the
nominal corner shape can otherwise leave less than one configured wall thickness.

The structural profile therefore unions a local support envelope around the
panel-derived reinforcement position:

```text
reinforcement support diameter
    physical bushing outside diameter
  + 2 × reinforcement clearance
  + 2 × wall thickness
```

The image deliberately uses the **small** preset. Gray is the unchanged family
profile; red is only the extra structural footprint required around the physical
reinforcement. Wider presets gain nothing where their existing arm already
contains that envelope.

<!-- scad-render
view: reinforcement-support-profile
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

Production exposes and constructs this footprint through:

```scad
hub75_corner_edge_coupler_reinforcement_relief_diameter(coupler)
hub75_corner_edge_coupler_reinforcement_support_diameter(coupler)
_hub75_corner_edge_coupler_reinforcement_support_envelope_2d(coupler)
_hub75_corner_edge_coupler_structural_profile_2d(coupler)
```

That structural profile is extruded from the panel mounting plane toward the
back of the display:

```text
Y = 0
    ↓
Y = base_thickness
```

<!-- scad-render
view: base
-->

The production module is:

```scad
_hub75_corner_edge_coupler_base_solid(coupler)
```

The normal `_hub75_corner_edge_coupler_profile_2d()` remains the family reference
contour used for surface markings. The local structural extension exists only
where the reinforcement clearance requires more load-bearing material.

## 7. Cut the corner screw bore

The nominal-corner coordinate system makes the physical screw position directly
visible. For the top variants the current panel geometry gives approximately:

```text
left   [+8, -8] mm
right  [-8, -8] mm
```

<!-- scad-render
view: screw-hole
-->

The position accessor is:

```scad
hub75_corner_edge_coupler_screw_position(coupler)
```

The Ø3.4 bore plus shallow anti-elephant-foot widening is created by:

```scad
_hub75_corner_edge_coupler_screw_cutter(coupler)
```

and the resulting base state is:

```scad
_hub75_corner_edge_coupler_base_after_screw_hole(coupler)
```

## 8. Add the blind mounting-tube pocket

The physical mounting tube around the screw protrudes through the rear mounting
plane, so the panel-facing side of the base needs a shallow fitted pocket.

Its derived dimensions are:

```scad
hub75_corner_edge_coupler_mounting_tube_pocket_diameter(coupler)
hub75_corner_edge_coupler_mounting_tube_pocket_depth(coupler)
```

<!-- scad-render
view: tube-pocket
-->

The production cutter and next base state are:

```scad
_hub75_corner_edge_coupler_mounting_tube_pocket_cutter(coupler)
_hub75_corner_edge_coupler_base_after_pocket(coupler)
```

The pocket remains blind; the structural screw bore still passes through it.

## 9. Clear the diagonal locating pin only where it exists

Only the left/top-left variant has a physical locating pin in this corner
relationship. The right/top-right variant does not.

The source makes that distinction explicit:

```scad
hub75_corner_edge_coupler_has_locator_pin(coupler)
hub75_corner_edge_coupler_locator_pin_position(coupler)
```

The pin is beyond the small and medium bodies. The **image intentionally uses
the large left preset**, where the 100 mm reach finally touches the physical pin.
Dark gray is the real pin, pale gray the base before the cut and red the required
clearance cutter.

<!-- scad-render
view: locator-pin-clearance
-->

The production subtraction is:

```scad
_hub75_corner_edge_coupler_locator_pin_clearance_cutter(coupler)
```

and all functional base clearances are collected in:

```scad
_hub75_corner_edge_coupler_base_after_functional_cutters(coupler)
```

Rotating the left part 180 degrees transfers the same clearance relationship to
the physical bottom-right corner.

## 10. Define the physical corner keep-out for the guides

The guide wall must occupy the space beside the panel rails, not the panel
material itself.

The guide construction therefore starts with:

```text
printable area
    rounded asymmetric corner profile

forbidden area
    real rear-corner panel material
    expanded by fit_clearance
```

The gray outline is the printable profile. Red is only the forbidden envelope
inside that profile.

<!-- scad-render
view: guide-keepout
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

Production gets the physical material from:

```scad
_hub75_corner_edge_coupler_panel_keepout_2d(coupler)
```

and applies printable clearance with:

```scad
offset(delta = coupler.fit_clearance)
```

## 11. Subtract the keep-out to make the raw guide shell

Before free-end trimming, the conceptual guide shell is simply:

```text
rounded corner profile
MINUS
clearance-expanded physical corner keep-out
```

<!-- scad-render
view: guide-raw-shell
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

This sharp explanatory intermediate does **not** have its own production helper.
The documentation adapter constructs it only to expose the Boolean subtraction.
The equivalent subtraction is the first half of:

```scad
_hub75_corner_edge_coupler_guide_shell_2d(coupler)
```

## 12. Trim the free guide ends without eroding thin walls

The corner family deliberately does not use a shrink/grow operation on the
entire guide shell. On the 2 mm small preset that could consume a complete thin
wall.

Instead, production intersects the raw fitted shell with a second corner profile
whose free-end radius is replaced by the safe effective guide rounding.

Gray is the raw shell from step 11. Red is the final production guide shell after
that intersection mask.

<!-- scad-render
view: guide-end-mask
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

The complete production operation is:

```scad
_hub75_corner_edge_coupler_guide_shell_2d(coupler)
```

with the bounded radius from:

```scad
_hub75_corner_edge_coupler_effective_guide_rounding(coupler)
```

The important property is that the mask can **only trim** the fitted shell; it
can never expand it or shift a panel-mating wall.

## 13. Split the shell and follow both physical outside tapers

A corner guide crosses two orthogonal physical panel edges. The source therefore
separates:

```text
inside-panel quadrant
    tall fitted guide

outside horizontal zone
    top outside ridge

outside vertical zone
    side outside ridge
```

Gray is the inward guide region. Red is the two rear-plane outside ridge
footprints.

<!-- scad-render
view: guide-zones
vpr: [0, 0, 0]
vpt: [8, 0, -8]
-->

The rear-plane split uses:

```scad
_hub75_corner_edge_coupler_inside_panel_2d(coupler)
_hub75_corner_edge_coupler_tall_guide_2d(coupler)
_hub75_corner_edge_coupler_horizontal_outer_ridge_2d(coupler)
_hub75_corner_edge_coupler_vertical_outer_ridge_2d(coupler)
```

Those rear footprints cannot simply be extruded straight toward the panel front.
The real HUB75 outside faces widen continuously over the physical taper depth.
The horizontal ridge must therefore move only its **panel-facing Z edge**; the
vertical ridge must move only its **panel-facing X edge**. Their exposed outside
coupler contour stays stationary.

Gray in the next image is the finished production ridge geometry. Red is only
the material removed from the old straight extrusion to accommodate the physical
X/Z taper. The two solids do not overlap, so the thin panel-facing wedges remain
visible without coincident transparent surfaces. This subtraction view explains
the change; production constructs the tapered ridges directly.

<!-- scad-render
view: guide-taper
vpr: [68, 0, 35]
vpt: [8, -2, -8]
-->

The panel-derived inputs are:

```scad
coupler.panel_taper_depth
coupler.panel_rear_outer_inset_x
coupler.panel_rear_outer_inset_z
hub75_panel_taper_shift_at_depth(...)
```

Production builds the two ridges **independently**:

```scad
_hub75_corner_edge_coupler_horizontal_outer_ridge(coupler)
_hub75_corner_edge_coupler_vertical_outer_ridge(coupler)
```

and unions them only afterwards in:

```scad
_hub75_corner_edge_coupler_outer_ridges(coupler)
```

Each ridge starts as a straight extrusion of its unchanged rear footprint.
An intersection with a panel-derived taper prism removes material only from the
panel-facing edge. The horizontal prism is a YZ polygon extruded along X; the
vertical prism is an XY polygon extruded along Z.

Do not hull the ridges, either together or individually: even one ridge has a
concave family outline, and its convex hull would fill that outline with unwanted
diagonal material. Intersecting the original extrusion preserves that outline.

## 14. Preserve a full wall around the corner reinforcement

The reinforcement support envelope introduced in step 6 is also the starting
boundary for the fitted guide shell. The real panel keep-out is still subtracted
first, so the local extension cannot grow back into panel material.

The final circular relief then removes exactly the physical reinforcement plus
print clearance:

```text
inner cleared diameter
    physical reinforcement outside diameter
  + 2 × reinforcement clearance

outer support diameter
    inner cleared diameter
  + 2 × wall thickness
```

This is the same rule as the horizontal-edge family and is not a small-only
special case. If medium or large already contain the support envelope, their
visible contour remains unchanged.

The first image keeps the supported coupler construction visible: gray is the
unrelieved guide; red is the cylindrical material-removal volume.

<!-- scad-render
view: guide-reinforcement-relief
alt: Corner supported guide reinforcement relief construction
-->

The detail image explains the physical reason. Dark gray is the HUB75
reinforcement feature, light gray the supported guide, transparent red the
required clearance band and bright red exactly the guide material that must be
removed.

<!-- scad-render
view: guide-reinforcement-detail
alt: Corner HUB75 reinforcement and supported guide clearance detail
size: [480, 360]
-->

Production uses:

```scad
hub75_corner_edge_coupler_reinforcement_relief_diameter(coupler)
hub75_corner_edge_coupler_reinforcement_support_diameter(coupler)
hub75_corner_edge_coupler_reinforcement_position(coupler)
_hub75_corner_edge_coupler_guide_walls(coupler)
```

The documentation adapter gives the embedded cylindrical subtraction a named
explanatory helper only so the Boolean operation can be shown independently.

## 15. Extrude the complete corner guide system

The inward guide is extruded to `guide_height` with the reinforcement relief
removed. The two outside ridges use that same 4 / 6 / 10 mm height, but their
panel-facing X/Z edges follow the continuous physical taper from step 13.

<!-- scad-render
view: guides
-->

Production uses:

```scad
_hub75_corner_edge_coupler_guide_walls(coupler)
_hub75_corner_edge_coupler_outer_ridges(coupler)
```

The latter is a union of two independently tapered ridge solids. It never hulls
the combined horizontal/vertical ridge set.

## 16. Add the reinforcement pad/pin locator

Inside the relieved circular region the coupler adds a positive two-stage
locator:

```text
large pad
    fits the panel reinforcement recess

small pin
    enters its blind centre hole
```

The printable dimensions are derived through:

```scad
hub75_corner_edge_coupler_reinforcement_locator_pad_diameter(coupler)
hub75_corner_edge_coupler_reinforcement_locator_pad_height(coupler)
hub75_corner_edge_coupler_reinforcement_locator_pin_diameter(coupler)
```

<!-- scad-render
view: reinforcement-locator
-->

The actual 3D feature is built by:

```scad
_hub75_corner_edge_coupler_reinforcement_locator(coupler)
```

Only the radial/axial print clearances and pin length are project-owned; the
panel recess and blind-hole dimensions come from `lib.scad.hub75`.

## 17. The complete functional corner

At this stage all geometry needed for physical panel fit is present and no
visible reference engraving has been added yet.

<!-- scad-render
view: functional
-->

Production collects that state in:

```scad
_hub75_corner_edge_coupler_functional_build(coupler)
```

which combines:

```scad
_hub75_corner_edge_coupler_base_after_functional_cutters(coupler)
_hub75_corner_edge_coupler_guide_walls(coupler)
_hub75_corner_edge_coupler_outer_ridges(coupler)
_hub75_corner_edge_coupler_reinforcement_locator(coupler)
```

## 18. Add the blind reference pockets

The visible rear face receives the family reference-pocket language:

```text
visible diameter        Ø3.0 mm
maximum blind depth      2.0 mm
small effective depth    1.3 mm
final taper              0.5 mm
bottom diameter          Ø2.0 mm
minimum back wall        0.7 mm
```

The raster starts from a symmetric virtual corner cross. The real asymmetric
corner profile then clips unsupported rows, so the pattern makes the nominal
versus physical rail offset visible.

<!-- scad-render
view: reference-pockets
vpr: [68, 0, 215]
-->

The effective depth comes from:

```scad
hub75_corner_edge_coupler_reference_pocket_effective_depth(coupler)
```

and the 3D subtraction from:

```scad
_hub75_corner_edge_coupler_reference_pocket_cutters(coupler)
```

That cutter preserves the cylindrical Ø3 visible section and applies the Ø3→Ø2
taper only at the pocket bottom.

## 19. Add the nominal-corner `+` and distance ticks

The `+` marks the actual component datum:

```text
X = 0
Z = 0
    nominal panel corner
```

Minor ticks occur every 5 mm and major ticks every 10 mm. They are generated in
both inward and outside directions, then clipped by the real asymmetric profile.
That makes the 19.5 mm outside limit and 30/40/50 mm inward reaches visible.

<!-- scad-render
view: center-marks
vpr: [68, 0, 215]
-->

The pattern is constructed by:

```scad
_hub75_corner_edge_coupler_center_marks_2d(coupler)
```

and cut shallowly by:

```scad
_hub75_corner_edge_coupler_center_mark_cutters(coupler)
```

The generated design view shows the already-cut reference pockets as part of the
gray previous state; only the newly introduced marks are red.

## 20. Complete left corner

The public production build combines the functional geometry and the two surface
reference layers.

<!-- scad-render
view: final
-->

The public API is:

```scad
coupler = hub75_corner_edge_coupler_create(side = "left");
hub75_corner_edge_coupler_build(coupler);
```

## Right variant

The right part is the X-mirrored mechanical counterpart. It uses the same
construction, radii, clearances, guide logic and surface language. Its physical
side-rail centre and screw coordinate are mirrored, and it has no top-corner
locator-pin clearance.

<!-- scad-render
view: right-final
-->

The variant is selected at object creation rather than by maintaining a separate
geometry implementation:

```scad
hub75_corner_edge_coupler_create(side = "right")
```

A 180 degree rotation maps:

```text
left  -> bottom-right
right -> bottom-left
```

## Fit verification

Left and right verification entrypoints provide local fit details plus three
true **0.10 mm** slices for every size:

```text
rear-fit XZ slice
    complete corner relationship at the selected insertion depth

YZ top-edge slice
    horizontal ridge against the physical Z taper

XY side-edge slice
    vertical ridge against the physical X taper
```

Each thin slice cuts on both sides of its section plane instead of keeping a
complete half-space. That makes the red/gray mating contours readable even where
the panel outside wall is sloped.

These verification images answer a different question from the construction
walkthrough:

```text
design.md
    How is the corner coupler constructed and why?

verification evidence
    Does that construction fit the authoritative HUB75 geometry in X, Y and Z?
```

## Deferred

The aluminium reinforcement tube and corner C-clip remain intentionally deferred.
The panel-fit geometry of the corner body, including both outside-ridge tapers,
is now explicit and independently verifiable before that reinforcement hardware
is introduced.
