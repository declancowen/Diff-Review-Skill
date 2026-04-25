# Benchmark Scoring

Use this to evaluate whether changes to the diff-review skill actually improve review quality.

## Scorecard

For each benchmark in `escaped-review-benchmarks.md`, score the review attempt:

| Score | Meaning |
|-------|---------|
| 0 | Missed the issue class entirely or gave false all-clear |
| 1 | Noticed a vague risk but did not identify the invariant or affected path |
| 2 | Identified the bug class and likely path but missed sibling/variant proof |
| 3 | Found the issue, named invariant, checked sibling/variant, recommended prevention |

## Evaluation Table

```markdown
| Benchmark | Score | Expected class | Found? | Missed proof | Skill change needed |
|-----------|-------|----------------|--------|--------------|---------------------|
| Server ID Authority During Create | 3 | Authority | yes | none | no |
| Batch Mutation Partial Success | 2 | Atomicity | partial | read-model invalidation | yes |
```

## Passing Bar

For a hardened review process:

- no `0` scores on Critical/High benchmark cases
- average score >= 2.5 across active benchmark set
- no false all-clear on a benchmark with a live High/Critical issue
- every miss has a named process improvement, not just "be more careful"

## When To Run

- after updating this skill
- after a real missed bug
- before trusting a new all-clear pattern on a high-risk branch
- when the user asks whether the review process is now strong enough

## How To Interpret Results

- Repeated low score on one bug class means the skill needs a stronger gate for that class.
- Repeated noisy false positives mean the taxonomy entry may be too broad or lacks proof standards.
- If the review finds the bug but misses the sibling path, improve variant/sibling proof, not severity wording.
- If the review finds the bug but under-ranks it, update `severity-calibration.md`.
