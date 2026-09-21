# 2026-009-02.cad.hub75-component-lab

Subproject lab for fast, isolated development and verification of HUB75 CAD components.

Parent project: `brainboxemb/2026-009-01.cad.HUB75-display-frame`.

## Current experiment

The first isolated component is the detachable Ø10 mm tube clamp from parent PR #45.
Imported baseline: `feature/pr-45-reinforcement-dovetail-clamps` at
`3db3e89e22c000572283ee4fe2e3e59cb8b34f29`.

The question is deliberately narrow: soften the sharp lower transition-foot edge
with a local round relief without reshaping the accepted clamp body or dovetail.

## Fast iteration loop

1. Run `./bootstrap.sh` or `bootstrap.ps1` once after cloning.
2. Open `dsg/openscad/main.scad` directly.
3. Use F5/Preview while tuning.
4. Switch between `baseline`, `relief`, `comparison` and `removed`.
5. Tune only `relief_radius`, `relief_bite` and `relief_face_depth`.
6. Use the normal SCAD build only for a candidate worth stable rendered evidence.

## Isolation boundary

Only `lib.scad.clamps v0.1.7` and `lib.scad.mechint v0.1.5` are retained.
The HUB75 panel library is omitted; its already-derived clamp datum is represented
locally by the 14.5 mm mounting plane, yielding Y = -8.5 mm for the Ø10 mm tube.

The parent HUB75 repository remains the production source of truth. Accepted
changes are ported back as a minimal delta and verified there.
