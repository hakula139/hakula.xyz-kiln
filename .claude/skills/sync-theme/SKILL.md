# Sync Theme

Update the IgnIt theme submodule and rebuild site assets. Use after pushing changes to the IgnIt repo (CSS, JS, templates) to propagate them into hakula.xyz-kiln.

## Steps

1. **Update submodule** to the latest commit on the active branch:

   ```bash
   git -C themes/IgnIt pull
   ```

2. **Rebuild site CSS / JS** (theme changes may affect compiled output):

   ```bash
   pnpm build
   ```

3. **Stage and commit** the submodule pointer and rebuilt assets:

   ```bash
   git add themes/IgnIt static/css/style.min.css
   git commit -m "chore: update IgnIt submodule, rebuild site CSS"
   ```

   Include `static/js/*.min.js` if JS files also changed.

4. **Push**:

   ```bash
   git push
   ```

## When to Use

- After committing and pushing changes in the IgnIt repo
- After updating the IgnIt submodule branch (e.g., switching from `main` to a feature branch)

## Common Mistakes

- Forgetting `pnpm build` after submodule update — the compiled CSS in `static/` will be stale
- Committing only the submodule pointer without the rebuilt `static/css/style.min.css`
- Not checking that the submodule is on the correct branch before pulling
