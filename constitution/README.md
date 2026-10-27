# The DnDGen Constitution

[CONSTITUTION.md](CONSTITUTION.md) holds the principles every DnDGen repository is built by.
There is one copy, here, and every repository reads it live, so a change to it reaches every
repository the moment it merges.

## How It Works

Spec Kit's commands read only the repository's own `.specify/memory/constitution.md`. In each
DnDGen repository, that file opens with a pointer telling the agent to fetch
[CONSTITUTION.md](CONSTITUTION.md) first, in full, and then adds only what is specific to that
repository, under the DnDGen constitution's labels: **II.2.c (Stress)**, for example.

[constitution-template.md](constitution-template.md) is the shape of that file. Each repository
installs it as a Spec Kit template override, so that `/speckit-constitution` keeps the pointer
instead of rebuilding the file from Spec Kit's default template.

A Spec Kit preset could carry the constitution instead, but a preset is installed by copying it
into each repository, and every copy drifts until someone updates it. The pointer means there is
nothing to update.

## Adopting It in a Repository

1. **Set up Spec Kit**, if the repository doesn't have it yet:

   ```
   specify init --here --integration claude --script ps
   ```

2. **Install the template override, before running `/speckit-constitution`:**

   ```powershell
   New-Item -ItemType Directory -Force .specify/templates/overrides
   Invoke-WebRequest https://raw.githubusercontent.com/DnDGen/.github/main/constitution/constitution-template.md -OutFile .specify/templates/overrides/constitution-template.md
   ```

3. **Run `/speckit-constitution`** to fill in the repository's own parts: its stack, how it is
   versioned and released, what its coverage measures, what its README must document, and any
   examples of its own. Then check that:
   - the pointer is unchanged,
   - every addition sits under a DnDGen label, and none is a new principle,
   - nothing contradicts the DnDGen constitution, and
   - the Sync Impact Report comment at the top is removed before committing.

   A repository that already has its own full constitution moves everything the DnDGen
   constitution now covers out of it, which is a MAJOR version of the repository's constitution.

4. **Check the first feature's plan.** The Constitution Check in its `plan.md` should cite the
   DnDGen constitution's labels (I.1, II.2.c, and so on), not just the repository's additions. If
   it cites only the additions, the agent didn't follow the pointer: open an issue here.

## Amending It

- **The DnDGen constitution** changes by pull request to this repository, following its own
  Governance section. The change reaches every repository when it merges, so check before merging
  that no repository's additions now contradict it.
- **A repository's additions** change by pull request to that repository, with
  `/speckit-constitution` or by hand.
- **The template** is the one part that is copied, so keep it to the pointer and the shape. A
  change to it reaches a repository only when step 2 is run there again.

Written for Spec Kit 1.2.2.
