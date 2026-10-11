---
name: sync-theme
description: Update the IgnIt theme submodule and verify the site build. Use after pushing changes to the IgnIt repo (CSS, JS, templates) to propagate them into hakula.xyz-kiln.
---

# Sync Theme

## Steps

1. **Update submodule** to the latest commit on IgnIt's default branch:

   ```bash
   git submodule update --init --remote themes/IgnIt
   ```

   To preview an unmerged IgnIt branch instead, run `git -C themes/IgnIt fetch` and then `git -C themes/IgnIt switch --detach origin/<branch>`.

2. **Build the site**, including CSS compilation:

   ```bash
   kiln build
   ```

3. **Stage and commit** the submodule pointer:

   ```bash
   git add themes/IgnIt
   git commit -m "<type>(template): <summary of the IgnIt change>"
   ```

4. **Push**:

   ```bash
   git push
   ```

## When to Use

- After committing and pushing changes in the IgnIt repo
- When previewing an IgnIt feature branch in the site

## Common Mistakes

- Skipping the site build after a submodule update
- Staging generated build output
