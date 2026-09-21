# Repository agent guidance

This repository is the isolated HUB75 CAD component lab for parent project
`brainboxemb/2026-009-01.cad.HUB75-display-frame`.

## Shared SCAD convention

Shared SCAD naming conventions are owned by
[brainboxemb.meta/domains/scad/coding-conventions.md](https://github.com/brainboxemb/brainboxemb.meta/blob/main/domains/scad/coding-conventions.md).
Use that convention for `d_` design inputs, `c_` presentation/Customizer
state, explicit unit suffixes, constants and leading-underscore private names.
Do not duplicate or redefine the shared naming scheme in this lab.

## Purpose

Keep geometry feedback loops small and fast. Develop one component problem at a
time with the minimum dependencies needed to reproduce it.

The parent HUB75 repository remains the production source of truth. This lab is
temporary development space; accepted geometry changes must be ported back to
the parent project rather than creating a second long-lived implementation.

## Working rules

- freeze scope to one component and one geometric question per iteration;
- keep the smallest useful standalone OpenSCAD entrypoint;
- depend on reusable libraries through the normal project dependency mechanism;
- do not copy reusable library implementation into this repository;
- remove parent-project dependencies when a small explicit local datum is enough;
- prefer direct component preview/render over whole-display builds;
- record parent source branch/commit when importing a component baseline;
- after acceptance, port the minimal delta back to the owning project/library
  and verify it there;
- once promoted, use the released/parent-owned implementation instead of keeping
  a second lab implementation of the same behavior.

## Current status

The first clamp experiment is complete.

- constant-wall tension behavior is owned by `lib.scad.clamps v0.1.8`;
- the accepted side relief is ported to parent PR #45 at
  `2a6e043c5c03ef95d175da3ad74c86a5394d55d3`;
- accepted relief calibration is R6 / 0.4 mm bite / 4 mm development-Z height /
  1 mm development-Z offset;
- parent PR #45 is the production source of truth.

Do not extend the completed clamp experiment with unrelated changes. Start the
next lab iteration only for a newly scoped component question.
