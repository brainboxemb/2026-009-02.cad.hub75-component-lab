# 2026-009-02.cad.hub75-component-lab

Subproject lab for fast, isolated development and verification of HUB75 CAD
components.

Parent project: `brainboxemb/2026-009-01.cad.HUB75-display-frame`.

## Status

The two clamp-focused experiments developed on PR #3 are complete. Production
ownership has moved back to the reusable libraries and the parent HUB75 project.

### Experiment 1 — Ø10 detachable tube clamp

Imported parent baseline:

```text
parent branch : feature/pr-45-reinforcement-dovetail-clamps
baseline SHA  : 3db3e89e22c000572283ee4fe2e3e59cb8b34f29
```

The accepted local side relief was calibrated here and ported back to parent
PR #45 at:

```text
2a6e043c5c03ef95d175da3ad74c86a5394d55d3
```

The associated tension-bore experiment exposed a reusable clamp-library issue.
Constant-wall tension behavior is now owned by released
`lib.scad.clamps v0.1.8`.

Accepted relief calibration:

```text
radius_mm    = 6.0
bite_mm      = 0.4
z_height_mm  = 4.0
z_offset_mm  = 1.0
```

The relief is symmetric on both physical clamp sides.

### Experiment 2 — printable male lock release

The second experiment qualified the male sliding-dovetail lock-release opening
in the actual baseline clip and side-print orientation.

Accepted result:

```text
lock_release_shape            = "trapezoid"
lock_release_taper_angle_deg  = 45
```

The functional rectangular release opening is not replaced or narrowed.
`lib.scad.mechint` retains that complete baseline cutter and removes two
additional symmetric X/Z wedges toward the male outer/trailing edge. The wedges
cover the complete visible release zone including the recess, keep release depth
constant, and extend slightly beyond the outer male face to avoid a Boolean
sliver wall.

That geometry is released as `lib.scad.mechint v0.1.6` from source commit:

```text
bdd39925f2ad391b32fad7ba56770053d4d5e2bc
```

The HUB75 production integration is on parent PR #45 at:

```text
9bda6dddec7eea0ddd1364d41cff6919b9c7b143
```

## Fast iteration loop

For a future newly scoped experiment:

1. Run `./bootstrap.sh` or `bootstrap.ps1` once after cloning.
2. Open `dsg/openscad/main.scad` directly.
3. Use F5/Preview while tuning.
4. Keep the experiment isolated to one geometric question.
5. Use the normal SCAD build only for a candidate worth stable PNG/STL evidence.
6. Once accepted, port the minimal delta to its owner and verify it there.

This repository remains a reproducible lab/reference harness. It is not a
production source for the clamp or dovetail libraries.

## Orientation terminology

The lab uses four fixed terms:

- **native orientation** — coordinate system owned by the source component or
  library;
- **project orientation** — production/assembly coordinates of the HUB75 parent;
- **design orientation** — convenient lab/CAD orientation used while designing
  and inspecting the component;
- **print orientation** — physical slicer/print-bed orientation.

A **view** is only a camera direction; it does not change the selected geometry
orientation.

For the clamp the design mapping is:

```text
project X -> design X
project Y -> design -Z
project Z -> design Y
```

This is a -90 degree rotation around project X.

## Isolation boundary

The completed clamp reference retains only:

- `lib.scad.clamps v0.1.8`;
- `lib.scad.mechint v0.1.6`.

The HUB75 panel library is omitted. Its already-derived mounting plane is
represented locally as 14.5 mm, yielding Y = -8.5 mm for the Ø10 mm tube.

The parent HUB75 repository remains the production source of truth. Accepted
changes are ported back as a minimal delta and verified there.

## Generated evidence

The lab build workflow is intentionally PR-oriented. During an active lab PR,
generated PNG/STL evidence is published to that PR's temporary
`dev/pr-N/bld` preview branch.

After merge, the normal PR cleanup removes both that preview branch and the
temporary source branch. This repository does not automatically publish a
`main` / `prod/bld` snapshot.

The retained evidence after lab completion is therefore the merged lab source
plus the promoted production implementations and their own build/verification
evidence:

- `lib.scad.clamps v0.1.8`;
- `lib.scad.mechint v0.1.6`;
- HUB75 parent PR #45.
