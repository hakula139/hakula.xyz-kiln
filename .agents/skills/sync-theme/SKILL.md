---
name: sync-theme
description: Update the IgnIt theme submodule and rebuild site assets. Use after pushing changes to the IgnIt repo (CSS, JS, templates) to propagate them into hakula.xyz-kiln.
---

# Sync Theme

## Steps

1. **Update submodule** to the latest commit on the active branch:

   ```bash
   git -C themes/IgnIt pull
   ```

2. **Rebuild site CSS / JS** (theme changes may affect compiled output):

   ```bash
   pnpm build
   ```

3. **Stage and commit** the submodule pointer and rebuilt CSS:

   ```bash
   git add themes/IgnIt static/css/style.css
   git commit -m "chore(theme): bump IgnIt to <short-sha>"
   ```

   Theme JS changes are captured by the submodule pointer alone, because kiln's `copy_static` ships `themes/IgnIt/static/js/` directly and the site has no JS artifact to rebuild.

4. **Push**:

   ```bash
   git push
   ```

## When to Use

- After committing and pushing changes in the IgnIt repo
- After updating the IgnIt submodule branch (e.g., switching from `main` to a feature branch)

## Common Mistakes

- Forgetting `pnpm build` after a submodule update, which leaves the compiled CSS in `static/` stale
- Committing only the submodule pointer without the rebuilt `static/css/style.css`
- Not checking that the submodule is on the correct branch before pulling
