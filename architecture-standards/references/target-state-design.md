# Target-State Design

Use this when defining or evaluating the desired architecture for a system. In existing repos, use this with `current-state-diagnosis.md`: target state is only useful if it explains how the current state will become safer and more coherent.

## Target State Is Not A Slogan

"Modular monolith," "clean boundaries," "thin routes," or "shared helpers" are not enough.

A usable target state defines:

- capability map
- ownership of invariants
- dependency direction
- public module/API surfaces
- data ownership and write authority
- contract ownership
- async/reliability model
- integration boundaries
- test and static enforcement
- operational ownership
- transition sequence from current state
- accepted exceptions and cleanup triggers

If an audit later finds widespread duplication, unclear ownership, and health pressure, the prior target state was probably too generic or lacked fitness functions.

## Design From Current-State Evidence

Start with:

- repo-audit findings and risk ranking
- duplication clusters
- complexity/health hotspots
- churn hotspots
- module-budget pressure
- repeated test fixture patterns
- boundary violations or weak import rules
- deployment/runtime evidence gaps
- failed or skipped verification
- prior accepted exceptions

Then ask what target architecture would make those findings less likely to recur.

## Required Target-State Decisions

### Capability Ownership

For each major capability, define:

- what it owns
- what it does not own
- public commands/queries/components/adapters
- private internals
- allowed dependencies
- tests/guards that protect its boundaries

### Invariant Ownership

For critical rules, define the authoritative layer:

- permissions and tenancy
- state transitions
- ranking/order/status rules
- visibility/publication rules
- IDs, slugs, hashes, tokens
- conflict handling
- retries/recovery
- defaults/bootstrap behavior

UI and routes may mirror or guide. They should not become the authority for durable rules.

### Contract Ownership

For API, CLI, webhook, import/export, generated-client, and storage contracts, define:

- owner
- shape
- version/compatibility policy
- error semantics
- test fixture
- migration/legacy behavior

### Shared Abstraction Rules

Define what may become shared:

- stable cross-cutting primitive
- capability-owned helper with clear callers
- domain rule owned by authoritative layer
- adapter/infrastructure mechanism
- presentational primitive with no hidden business policy

Define what must not become shared:

- business policy without owner
- mixed UI/domain behavior
- route runner that hides security semantics
- test helper that obscures runtime contract

### Enforcement

A target state should include fitness functions:

- import/boundary tests
- analyzer config and thresholds
- module budgets
- contract tests
- data/invariant tests
- browser smoke for broad UI surfaces
- deployment smoke for third-party/env behavior
- stale suppression/baseline review

Without enforcement, target state is aspiration.

## Transition Design

A target state for a messy repo needs a path:

1. **Containment:** prevent new boundary drift, new duplicated policy, or new oversize modules.
2. **Risk-first correction:** fix auth, tenancy, data ownership, contracts, async reliability, and deployment gates.
3. **Capability refactors:** move repeated policy into owners and split mixed-responsibility modules.
4. **Presentation/test cleanup:** reduce UI and fixture duplication with behavior-preserving proof.
5. **Hardening:** remove allowlists, reduce baselines, tighten gates, and close deployment evidence.

Each slice needs:

- owner
- scope
- behavior-preserving tests
- expected metric/policy delta
- residual debt state

## Quality Bar

A good target-state design can answer:

- Where does this rule live?
- Who can call it?
- Who cannot call it?
- How is it tested?
- What static rule would catch a bypass?
- What happens during retries, partial failure, or stale state?
- What legacy data/client/job path still exists?
- What exception is temporary, and when does it go away?

## Anti-Patterns

- Target state ignores the current repo's worst duplication and health clusters.
- Target state names layers but not owners.
- Target state says "shared utilities" instead of capability-owned contracts.
- Target state relies on humans remembering boundaries.
- Target state has no transition sequence.
- Target state treats analyzer baselines, suppressions, or allowlists as completion.
- Target state claims production readiness without deployment/env/third-party verification.
