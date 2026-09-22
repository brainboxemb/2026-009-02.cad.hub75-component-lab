# Corner-edge clamp integration lab

## Parent baseline

This lab iteration reproduces only the project-owned geometry needed to study the
corner-edge tube-mount interface.

```text
parent repository : brainboxemb/2026-009-01.cad.HUB75-display-frame
parent branch     : main
parent commit     : 06191e400bc8b334af929274defbed627df461f6
lab issue / PR    : #7
```

The parent repository remains the production source of truth. This lab branch is
an isolated design harness, not a second production implementation.

## Question

How can the detachable tube clamp be integrated into the existing corner-edge
coupler body while preserving:

- the accepted core-coupler exterior;
- the existing side-rail-centre interface datum;
- top-entry insertion along project +Z;
- continuous Ø10 tube clearance;
- a usable female sliding-dovetail and lock/release path;
- rear-face-down printing of the coupler?

The first iteration is deliberately **corner-edge only**. The horizontal-edge
carrier geometry is a separate problem and is out of scope here.

## Baseline geometry to reproduce

The production chain to snapshot is:

```text
core corner-edge coupler
    +
tube-mount corner wrapper
    +
HUB75 tube clamp adapter
    +
HUB75 mechanical-interface adapter
    +
lib.scad.clamps
    +
lib.scad.mechint
```

Only the minimum parent-owned files needed for this chain should be copied into
the lab. Reusable library implementations remain dependencies and must not be
copied.

## Inspection sequence

1. Reproduce the current medium left-corner production baseline.
2. Show the core coupler alone.
3. Show the tube keep-out.
4. Show the female dovetail cutter.
5. Show the swept clamp insertion keep-out.
6. Show the installed clamp and Ø10 tube.
7. Add a focused section through the interface.
8. Inspect the rear-face-down print orientation.
9. Compare candidate simplifications or shape changes one at a time.

## Acceptance for this lab iteration

A candidate is worth porting back only when the evidence makes all of these
readable:

- where the load path enters the existing corner body;
- how much host material remains around the female interface;
- whether the complete clamp can enter from +Z without collision;
- whether the tube has continuous clearance;
- whether the lock/release area remains accessible;
- whether the resulting coupler is practical to print rear-face-down.

Physical fit is not claimed by this lab. It remains a later qualification step
in the parent project.


## Active lab entrypoints

The active interactive workbench is:

```text
dsg/openscad/main.scad
```

The first stable build target is:

```text
dsg/openscad/render/corner-edge-clamp-baseline.scad
```

The render deliberately shows the unmodified medium left-corner production
snapshot with the real detachable clamp adapter and a simple Ø10 reference tube.

The previous clamp-relief/tension/lock-release experiments are complete and no
longer participate in normal build target discovery. Their accepted outcomes are
owned by the released libraries and parent project; Git history retains the lab
iterations that produced them.


## Maintenance refresh

The parent baseline was refreshed after the HUB75 maintenance pass on
2026-09-22.

```text
previous parent baseline : 267abce8a3ac6e65f493618d2d4cc03164ea9911
current parent baseline  : 06191e400bc8b334af929274defbed627df461f6
```

The relevant maintenance changes are implementation cleanups, not a new product
geometry decision:

- corner core uses targeted Forge CSG/cutter vocabulary where it clarifies intent;
- corner tube-mount wrapper uses the current Forge cutter/transform vocabulary;
- detachable clamp uses the current Forge CSG composition;
- STL print orientation is now owned at the parent export/manufacturing boundary
  and is therefore not copied into this lab geometry harness.

The lab continues to study the same corner integration question against this
maintained parent source.
