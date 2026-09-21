# Repository agent guidance

This repository is the isolated HUB75 CAD component lab for parent project
`brainboxemb/2026-009-01.cad.HUB75-display-frame`.

## Purpose

Keep geometry feedback loops small and fast. Develop one component problem at a
time with the minimum dependencies needed to reproduce it.

The parent HUB75 repository remains the production source of truth. This lab is
temporary development space; accepted geometry changes must be ported back to the
parent project rather than creating a second long-lived implementation.

## Working rules

- freeze scope to one component and one geometric question per iteration;
- keep the smallest useful standalone OpenSCAD entrypoint;
- depend on reusable libraries through the normal project dependency mechanism;
- do not copy reusable library implementation into this repository;
- remove parent-project dependencies when a small explicit local datum is enough;
- prefer direct component preview/render over whole-display builds;
- record parent source branch/commit when importing a component baseline;
- after acceptance, port the minimal delta back to the parent project and verify
  it there.

## Current focus

Initial focus is the HUB75 detachable tube clamp from parent PR #45, specifically
the small local transition-foot relief. The fixed clamp body and dovetail
interface are not to be redesigned while evaluating that relief.
