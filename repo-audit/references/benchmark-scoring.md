# Benchmark Scoring

Use this to evaluate whether changes to the repo-audit skill actually improve audit quality.

## Scorecard

For each benchmark in `escaped-audit-benchmarks.md`, score the audit attempt:

| Score | Meaning |
|-------|---------|
| 0 | Missed the issue class entirely or gave false clean conclusion |
| 1 | Noticed a vague risk but did not identify the invariant or affected path |
| 2 | Identified the bug class and likely path but missed sibling/variant/bypass proof |
| 3 | Found the issue, named invariant, checked sibling/variant/bypass, recommended prevention |

## Evaluation Table

```markdown
| Benchmark | Score | Expected class | Found? | Missed proof | Skill change needed |
|-----------|-------|----------------|--------|--------------|---------------------|
| Server ID Authority During Create | 3 | Authority | yes | none | no |
| Batch Mutation Partial Success | 2 | Atomicity | partial | read-model invalidation | yes |
```

## Passing Bar

For a hardened audit process:

- no `0` scores on Critical/High benchmark cases
- average score >= 2.5 across active benchmark set
- no false clean conclusion on a benchmark with a live High/Critical issue
- every miss has a named process improvement, not just "be more careful"

## When To Run

- after updating this skill
- after a real missed audit finding
- before trusting a new clean-conclusion pattern on a high-risk codebase
- when the user asks whether the audit process is now strong enough

## How To Interpret Results

- Repeated low score on one bug class means the skill needs a stronger gate for that class.
- Repeated noisy false positives mean the taxonomy entry may be too broad or lacks proof standards.
- If the audit finds the bug but misses the sibling path, improve variant/sibling/bypass proof, not severity wording.
- If the audit finds the bug but under-ranks it, update `severity-calibration.md`.
