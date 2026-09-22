# Repository update qualification

This lab iteration qualifies one repository-maintenance composition before any
portfolio rollout.

Owner revisions under test:

```text
tool.git-project  045df0a8bd2007caf29fb625554a0b7853f90a87
tool.scad-project 229aea1475d3fda2dc9252e6e442708df44b8812
```

The intended consumer path is:

```text
root update-repo.*
    -> tool.git-project update
        -> generic dependency update
        -> role:tooling post-update hook
            -> tool.scad-project/consumer/post-update.*
                -> SCAD reusable-workflow ref synchronization
```

The root launcher remains generic and Python-free. SCAD owns only its
post-update behavior.
