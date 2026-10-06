---
name: sync-theme
description: Update the IgnIt theme submodule and verify the site build. Use after pushing changes to the IgnIt repo (CSS, JS, templates) to propagate them into hakula.xyz-kiln.
---

# Sync Theme

## Steps

1. **Update submodule** to the latest commit on the active branch:

   ```bash
   git -C themes/IgnIt pull
   ```

2. **Build the site**, including CSS compilation:

   ```bash
   kiln build
   ```

3. **Stage and commit** the submodule pointer:

   ```bash
   git add themes/IgnIt
   git commit -m "chore(theme): bump IgnIt to <short-sha>"
   ```

   Generated CSS stays in the ignored build output. Theme JavaScript ships directly from `themes/IgnIt/static/js/`.

4. **Push**:

   ```bash
   git push
   ```

## When to Use

- After committing and pushing changes in the IgnIt repo
- After updating the IgnIt submodule branch (e.g., switching from `main` to a feature branch)

## Common Mistakes

- Skipping the site build after a submodule update
- Staging generated build output
- Not checking that the submodule is on the correct branch before pulling
