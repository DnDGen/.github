# DnDGen Constitution

The principles every DnDGen repository is built by. Each repository's own constitution, in
`.specify/memory/constitution.md`, points here and adds only what is specific to that repository
(see Governance). This file is the only copy: repositories read it live, so it is never copied
into them. How a repository adopts it is in [README.md](README.md).

## Core Principles

### I. Consistency Is King

A codebase that does everything one way is easier to work in than a "cleaner" one that does
things a hundred ways. Consistency is the first test of any change.

**I.1 Emulate what exists, in this repository first, then across DnDGen.** The preferred
implementation follows the patterns and practices already in the repository being changed. When it
has no precedent, look to the other DnDGen repositories before inventing one: what's new to one
repository is often established elsewhere. Confirm a pattern from more than one example before
treating it as the convention.

- *Example:* RollGen's expression evaluation gained caching through
  `ExpressionEvaluatorCachingProxy`, a caching proxy around `AlbatrossExpressionEvaluator` that
  follows the proxy structure in DnDGen.Infrastructure, instead of caching inside the evaluator.

**I.2 A new pattern must be worth everyone conforming to it.** Adopting one is a decision for the
whole codebase, though the move happens incrementally as code is touched (III.2). A pattern is
worth it when it is clearer (I.2.a) or measurably better (I.2.b), and gives one answer the whole
codebase can follow (I.2.c); otherwise the existing pattern stays. IDE and analyzer suggestions are
new patterns too, judged the same way, and only when the IDE offers a quick fix that doesn't change
behaviour. A suggestion with no fix is ignored.

- **I.2.a Clearer to a reader**, not just shorter or more explicit.
  - *Examples:* Collection expressions and removing a redundant cast pass. Explicit types instead
    of `var` fail, because a good name should already say what the variable is; so do ternaries
    in place of `if`, and `_ =` in front of every ignored return value.
- **I.2.b Measurably better.** The benefit can be measured and is big enough to notice: a change
  within about ±10% counts as no change. Work like this is its own change, not part of another
  (III.3).
  - *Example:* In CreatureGen, pre-caching template-based creature groups made the verifier much
    faster. A 17% speed-up would qualify; a 7% one would not.
- **I.2.c One answer the whole codebase can follow.**
  - *Examples:* Block and expression bodies flip-flop with each other, so neither is enforced;
    expression bodies are preferred for one-line members. Braces may be left off only when every
    branch of an `if`/`else` is a single line.

**I.3 Code reads like well-written prose.** Names and structure carry the meaning, so a reader can
follow the code without comments. Design follows SOLID, with each concern kept in its own place.
Comments are added only by a human, or when a human asks for one, and only to record what the code
cannot say:

- **I.3.a `//INFO:`** why a choice was made, typically so a later change doesn't undo it and break
  things.
- **I.3.b `//HACK:`** an acknowledged poor solution.
- **I.3.c `//BUG:`** an acknowledged known defect.

### II. Tests Are the Spec

Behaviour is defined by tests before it is implemented: write or change the tests first, see them
fail for the expected reason, then change the code until they pass.

**II.1 What to test: what a consumer does and sees.**

- **II.1.a** Each case is a sentence from the consumer's side: "if I do X, I expect Y, and I'll
  confirm that with Z."
- **II.1.b** The list of cases is written as if the implementation had never been seen, and cases
  are named as consumer outcomes, in the consumer's vocabulary.
- **II.1.c** Every capability and option has its own case, even when two cases run the same lines
  of code.

**II.2 How much to test: everything when it's cheap, a deliberate sample when it isn't.**

- **II.2.a** When the valid range of an input is small enough, test all of it.
- **II.2.b** Otherwise, sample the range deliberately:
  - **II.2.b.i** Anything that counts or repeats is tested at 0, 1, and many. "Many" is the
    largest realistic count: a number that would expose off-by-one or batching mistakes, such as
    10 or 1337, is stronger, but 2 is fine where larger counts aren't realistic.
    - *Example:* CreatureGen tests chaining 0, 1, and 2 templates, and a few chains of 3. Chaining
      10 templates isn't realistic.
  - **II.2.b.ii** A wide range is tested at each order of magnitude.
    - *Example:* For 1 to 1,000,000: 1, 2, 10, 100, 1,000, 10,000, 100,000, and 1,000,000.
  - **II.2.b.iii** Every boundary and limit is tested, along with the value just inside it and
    values one step and more than one step past it: 0, 1, and many applied to the distance from
    the boundary.
    - *Example:* For a lower limit of 1: 2, 1, 0, and -1.
    - *Example:* Converting a double to a bool, 1 and 2 are true and 0 is false. Testing past the
      boundary showed that -1, 0.5, and -0.5 are all true: only 0 is false.
- **II.2.c** Coverage confirms nothing was missed, and never decreases. Line and branch coverage
  are measured on every change, and no change may lower either one. 100% is the goal; until a
  repository reaches it, holding steady is fine and dropping is not, and once it is reached, this
  rule keeps it there. An uncovered line is either a missing case or code that can never run. Code
  that can never run is removed only after showing why it can't run, what it was originally there
  for, and that removing it changes nothing a consumer can observe, and after the maintainer
  agrees.
  - *Example:* At 17.3%, a change that leaves coverage at 17.3% passes, and one that drops it to
    17.2% must add the missing cases first.

**II.3 How a test fails: when (not if) it fails, it says exactly where, why, and what to fix.**

- **II.3.a** Use the strongest assertion available: compare the whole observed value, so the
  failure shows what actually happened.
  - *Example:* Compare the entire collection, not just its count.
  - *Example:* For a complex object, a run of assertions on each of its properties is fine, as
    long as together they cover the whole object.
- **II.3.b** No implied assertions: everything a test relies on is written down in the test.
  - *Example:* The current pattern of chained mocks (input → mock A → mock B → mock C → result),
    each answering only its exact expected input, counts as written down, because a correct result
    proves every link. A broken link shows up only as a wrong final result; a better pattern for
    that can replace this one once it's agreed (I.2).
- **II.3.c** A failure means one thing: this case found a defect in the code. Each case runs,
  passes, and fails on its own, and none fails because of the machine, timing slack, or another
  test.

### III. Leave It Better Than You Found It

Every change may also improve the code it touches, as long as the improvement doesn't change
behaviour.

**III.1 In scope: maintenance.**

- **III.1.a** Updating packages and platforms, including major versions. An update that breaks
  something is fixed in the same change, or held back with the reason stated in the pull request.
- **III.1.b** Replacing outdated patterns and practices with the codebase's agreed ones, including
  IDE suggestions that pass I.2.
- **III.1.c** Correcting stale comments and documentation, or removing them once they're no longer
  true. New comments still follow I.3.

**III.2 Improve where you are, in its own commit.** Improvements are made in the code already being
changed, each in its own commit. An improvement made in one place, especially a new pattern, does
commit the codebase to the same improvement everywhere, but not immediately: the rest of the
codebase gets it the next time it is touched.

**III.3 Out of scope: behaviour.** Bug fixes, performance work, or features discovered along the
way are recorded as GitHub issues so they aren't lost, and handled as their own changes.

**How the three interact:** an improvement (III) moves the code toward the codebase's agreed
patterns (I) and stays green against the tests (II). Extensive automated coverage is what makes
routine cleanup safe, and improving only where you are keeps each change small.

## Technology & Release Constraints

- **Stack**: Each repository names its own stack in its constitution. Where a platform has
  Long-Term Support releases, a repository targets the latest one, never a Standard-Term Support
  release. A repository found to be behind the latest LTS upgrades as maintenance (III.1.a).
- **Versioning and release of NuGet packages**: Semantic versioning in the csproj `<Version>`.
  MAJOR for breaking changes, including removing or renaming public members, changing defaults,
  and raising the minimum version of the runtime or of a dependency consumers also use. MINOR for
  additive public API or options. PATCH for fixes, internal changes, and changes outside the
  package itself, such as dependencies, the pipeline, documentation, or Spec Kit. Every merge to
  `main` is a release: its pull request bumps `<Version>`, replaces `<PackageReleaseNotes>` with
  notes for that release only, and is titled `X.Y.Z: <summary>`. A release that doesn't change the
  package says so, names the last version that did, and points to the GitHub releases page; anyone
  upgrading across several versions reads each version's changes there. Each package's
  constitution names its own pipeline and any further MAJOR changes. Repositories that aren't
  NuGet packages state their own versioning in their constitution.
- **README as contract**: A NuGet package's README is packed into the package and is the only
  documentation consumers see. It documents every public member and option, with its default,
  states which runtime and dependency versions each major version requires, and is updated in the
  same pull request as any change to them. Each package's constitution lists what its README must
  document. In every repository, documents derived from the README, such as its theme song in
  `docs/theme-song`, say how they are kept in step with it, and are updated in the same pull
  request as the README change that affects them.

## Development Workflow

- Changes are made on a branch, reach the repository's `main` in the DnDGen organisation by pull
  request, and are reviewed by the maintainer.
- Pull request descriptions are written from the actual diff against `main`, and state what was
  verified and what was not.
- Spec Kit artifacts under `specs/` record one change at the time it was made. They are not
  maintained after the change merges, and MAY be deleted later. The lasting record of how a
  repository behaves is its tests (II), its README, and its constitution with this one.

## Governance

This constitution supersedes other practices in every DnDGen repository.

- **Repository constitutions** extend this one and never contradict it. A repository that needs
  an exception amends this constitution instead. Each one is built from
  [constitution-template.md](constitution-template.md): it opens with the template's pointer, so
  that every Spec Kit command reads this file live, and then adds only what is specific to the
  repository: its stack, how its versions and releases work, what its coverage measures, what its
  README must document, and its own examples. Each addition sits under the label it extends, such
  as **II.2.c (Stress)**, rather than as a new principle.
- **Rule of three, at every level.** There are about three core principles, and about three
  points under each. Needing more usually means some points are expressions of one underlying
  idea; naming that idea tends to reshape the other principles too. A new principle or point
  merges with or replaces an existing one rather than simply being added.
- **Amendments** are made by pull request to DnDGen/.github, with the reasoning in the pull request
  description, and take effect in every repository when they merge. They are versioned
  semantically: MAJOR for removing or redefining a principle, MINOR for a new principle or
  materially expanded guidance, PATCH for clarifications and wording. Principles are labelled
  I, II, III; their points I.1, I.2; sub-points I.2.a; and a further level II.2.b.i, so that plans
  and reviews can cite them. Examples sit unlabelled under the rule they illustrate. A repository
  constitution versions its own additions the same way.
- **Compliance**: Every plan and pull request is checked against these principles and the
  repository's additions, citing them by label. A deviation MUST be justified in the pull request,
  or the change is not merged.

**Version**: 1.0.0 | **Ratified**: 2026-10-27 | **Last Amended**: 2026-10-27
