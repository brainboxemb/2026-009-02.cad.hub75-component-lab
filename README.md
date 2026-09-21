# 2026-009-02.cad.hub75-component-lab

Subproject lab for fast, isolated development and verification of HUB75 CAD
components.

Parent project: `brainboxemb/2026-009-01.cad.HUB75-display-frame`.

## Status

The first isolated experiment — the detachable Ø10 mm tube clamp from parent
PR #45 — is complete.

Imported baseline:

```text
parent branch : feature/pr-45-reinforcement-dovetail-clamps
baseline SHA  : 3db3e89e22c000572283ee4fe2e3e59cb8b34f29
```

The accepted local relief was calibrated in this lab and then ported back to the
parent component. The production implementation is now on parent PR #45 at:

```text
2a6e043c5c03ef95d175da3ad74c86a5394d55d3
```

The tension experiment also produced a reusable-library correction. That behavior
is now owned by released `lib.scad.clamps v0.1.8`; the lab uses that release
instead of retaining a second implementation.

## Accepted relief calibration

The accepted development-orientation controls are:

```text
relief_radius   = 6.0
relief_bite     = 0.4
relief_z_height = 4.0
relief_z_offset = 1.0
```

For the 12 mm clamp width the cylinder centres are derived as:

```text
abs(X) = clamp_width / 2 + radius - bite = 11.6 mm
```

The same relief is applied on both physical clamp sides.

## Fast iteration loop

For an active experiment:

1. Run `./bootstrap.sh` or `bootstrap.ps1` once after cloning.
2. Open `dsg/openscad/main.scad` directly.
3. Use F5/Preview while tuning.
4. Keep the experiment isolated to one geometric question.
5. Use the normal SCAD build only for a candidate worth stable PNG/STL evidence.
6. Once accepted, port the minimal delta to its owner and verify there.

The current clamp workbench still exposes the completed experiment as reference
evidence while parent PR #45 is being reviewed. It must not become the production
source of the clamp.

## Orientation terminology

The lab uses four fixed terms:

- **native orientation** — coordinate system owned by the source component or
  library;
- **project orientation** — production/assembly coordinates of the HUB75 parent;
- **development orientation** — convenient lab/CAD orientation;
- **print orientation** — physical slicer/print-bed orientation.

A **view** is only a camera direction; it does not rotate the geometry.

For the clamp the development mapping is:

```text
project X -> development X
project Y -> development -Z
project Z -> development Y
```

This is a -90 degree rotation around project X.

## Isolation boundary

The current clamp reference retains only:

- `lib.scad.clamps v0.1.8`;
- `lib.scad.mechint v0.1.5`.

The HUB75 panel library is omitted. Its already-derived mounting plane is
represented locally as 14.5 mm, yielding Y = -8.5 mm for the Ø10 mm tube.

The parent HUB75 repository remains the production source of truth. Accepted
changes are ported back as a minimal delta and verified there.
