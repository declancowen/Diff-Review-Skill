# Current-State Architecture Diagnosis

Use this when an existing repo is messy, a target-state architecture has not held up in practice, or an audit reveals widespread duplication, complexity, unclear ownership, boundary drift, or refactor backlog.

This is different from target-state design. Target-state design says what the architecture should be. Current-state diagnosis explains why the existing system is not functioning effectively and what sequence can move it without breaking behavior.

## Diagnostic Stance

Start from evidence:

- code shape
- dependency direction
- duplicate policy
- health hotspots
- churn hotspots
- module size pressure
- test and smoke coverage
- CI/static gates
- audit and review history
- accepted exceptions, baselines, suppressions, and allowlists
- production/deployment verification gaps

When Fallow evidence exists, preserve its scope:

- changed-file audit versus repo-wide inventory
- production configured gate versus full non-production inventory
- duplication budget versus semantic duplication map
- configured threshold pass versus advisory hotspot/refactor target
- CI blocking gate versus `continue-on-error` advisory step

Do not let architecture docs, intended boundaries, or a scorecard override what the code is showing.

## Failure Modes To Look For

### Unclear Ownership

Signals:

- same business rule repeated in UI, route, domain, and data code
- shared helpers with business-specific behavior
- modules named `utils`, `helpers`, `common`, or `services` absorbing unrelated rules
- multiple ways to mutate the same state
- tests relying on duplicated setup instead of a contract fixture

Diagnosis:

- name the missing owner
- decide the authoritative layer
- identify callers that bypass it

### Boundary Theater

Signals:

- folders look layered but imports cross inward/outward freely
- analyzer boundary rules are weak, missing, or configured only after the fact
- public APIs expose persistence/vendor/transport shapes
- generated clients or route exports hide real coupling

Diagnosis:

- compare intended dependency direction with actual imports
- identify which boundary has no enforcement
- decide whether config, tests, or module placement should enforce it

### Scattered Policy

Signals:

- semantic duplication across capabilities
- similar validation/error/access logic in multiple routes
- status/rank/workflow/visibility rules repeated in UI and backend
- fallback/default/bootstrap code overwrites authoritative state

Diagnosis:

- distinguish user-guidance checks from authoritative policy
- move durable rules to the owning domain/application/data boundary
- keep UI mirrors thin and non-authoritative

### Mixed Responsibility Modules

Signals:

- files combine rendering, data fetching, access checks, state transitions, persistence, vendor calls, and formatting
- health hotspots are also churn hotspots
- module budget exceptions become permanent
- tests must mock too many unrelated things to exercise one behavior
- coverage-first tests need production-only exports because the useful branch is buried in a monolith

Diagnosis:

- split by responsibility and owner, not by line count
- keep orchestration visible
- extract pure policy where tests can prove it
- prefer owner-local sibling modules that production imports over exporting internals from the monolithic file

### Unowned Contracts

Signals:

- CLI/API/import/export/webhook contracts are represented by duplicated shapes
- tests assert happy path but not compatibility, conflict, or legacy payload behavior
- server URL/env/proof/hash/token rules appear in multiple places

Diagnosis:

- identify the contract owner
- define the narrow shared contract module or adapter
- add compatibility tests where old clients/data/jobs exist

### Weak Fitness Functions

Signals:

- architecture score is high but static analysis later exposes broad structural debt
- CI checks pass but warnings are ignored
- browser smoke is skipped or deployment-gated without release checklist
- baselines/allowlists are treated as completion
- production Fallow gates pass while full inventories still show unclassified debt
- local package scripts block stricter Fallow gates than CI does
- health score is used as a target while findings, duplication, and dead-code modes are not separately checked
- PR review finds a contract bug after local green tests because only the happy path or helper shape was asserted

Diagnosis:

- separate repo-code evidence from deployment evidence
- promote warnings/inventories into reviewed ledgers
- add tests/static checks that would catch relapse
- assert public serialized contracts at the route/API/job edge, not only internal helper options

Benchmark example: if an audit later reveals hundreds of dead-code findings, hundreds of clone groups, and dozens of critical health hotspots, the current-state diagnosis was too local. It needs both path thinking and shape thinking: trace key journeys, then cluster duplication, health, module size, helper sprawl, and exceptions into missing ownership or boundary concepts.

## Diagnosis Workflow

1. **Map actual architecture.**
   Read entry points, high-risk modules, import boundaries, data ownership, jobs, integrations, tests, and analyzer config.

2. **Cluster structural evidence.**
   Group duplication, health, churn, module size, and audit findings by capability and repeated responsibility.

3. **Name failure modes.**
   Use the categories above. Avoid vague "messy" labels; say which ownership or boundary is failing.

4. **Design containment.**
   Decide what must stop getting worse immediately: CI gate, boundary test, module budget, no-new-duplication gate, browser smoke, or contract test.

5. **Design transition slices.**
   Sequence refactors by risk:
   - first: security, tenancy, data ownership, contract correctness
   - second: high-churn hotspots and duplicated policy
   - third: broad presentation cleanup and module-size hardening
   - fourth: raw/advisory inventories and polish

6. **Define closure evidence.**
   Each slice needs behavior proof, static proof, or deployment proof. Metrics alone are insufficient.

7. **Record accepted debt.**
   Accepted debt needs owner, reason, trigger, and cap. Otherwise it is not accepted; it is untracked.

## Output Shape

A useful current-state architecture diagnosis includes:

- actual architecture shape
- intended architecture shape
- structural failure modes
- evidence clusters
- risk ranking
- immediate containment gates
- transition slices
- enforcement plan
- residual debt ledger
- deployment or runtime evidence gaps

## Anti-Patterns

- Designing an ideal target state without explaining why current state failed.
- Treating duplication counts as cleanup rather than ownership evidence.
- Treating complexity targets as "split files" rather than mixed-responsibility diagnosis.
- Treating analyzer zero as architecture completion.
- Accepting allowlists/baselines without owner and revisit trigger.
- Adding shared helpers before naming the invariant and owner.
- Calling broad UI refactors safe without visual/browser proof.
- Calling backend/domain refactors safe without contract or invariant tests.
