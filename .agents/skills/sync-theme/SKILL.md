---
name: sync-theme
description: Update the IgnIt theme submodule and verify the site build. Use after pushing changes to the IgnIt repo (CSS, JS, templates) to propagate them into hakula.xyz-kiln.
---

# Sync Theme

Update the `themes/IgnIt` submodule to the latest commit on IgnIt's default branch.

To preview an unmerged IgnIt branch, fetch its refs in `themes/IgnIt` and select the remote branch's commit with a detached HEAD.

Run the repository's [verification](../../../AGENTS.md#verification), then publish the submodule pointer change through the shared `git-workflow` skill.
