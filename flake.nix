# ==============================================================================
# hakula.xyz-kiln Site Development Flake
# ==============================================================================
#
# Provides Tailwind toolchain, pagefind, and pre-commit hooks. kiln itself is
# brought in externally.
#
#   nix develop                            # interactive shell (auto-installs hooks)
#   nix flake check                        # run Nix-side hooks in CI
#
# `nix flake check` only fires the Nix-side hooks (nixfmt, statix, deadnix,
# basic file hygiene). Node-side hooks (prettier, markdownlint, cspell)
# no-op when `node_modules/` is absent — CI's `check` job runs the Node
# equivalents directly via `pnpm`, so coverage is preserved without
# duplicating `pnpm install` in the `nix-check` job.

{
  description = "hakula.xyz-kiln — site source for hakula.xyz (dev environment)";

  # ----------------------------------------------------------------------------
  # Inputs
  # ----------------------------------------------------------------------------
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-utils.url = "github:numtide/flake-utils";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  # ----------------------------------------------------------------------------
  # Outputs
  # ----------------------------------------------------------------------------
  outputs =
    {
      nixpkgs,
      flake-utils,
      git-hooks-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # ----------------------------------------------------------------------
        # Node Hook Wrapper
        # ----------------------------------------------------------------------
        # `pnpm exec` needs node + pnpm on PATH and the project's
        # `node_modules` materialised. The Nix sandbox lacks the latter, so
        # `nix flake check` skips these hooks; the equivalent checks run in
        # CI via direct `pnpm` scripts.
        nodeHook =
          name: cmd:
          let
            wrapper = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [
                pkgs.nodejs_22
                pkgs.pnpm
              ];
              text = ''
                if [ ! -d node_modules ]; then
                  exit 0
                fi
                pnpm exec ${cmd} "$@"
              '';
            };
          in
          "${wrapper}/bin/${name}";

        # ----------------------------------------------------------------------
        # Pre-commit Hooks
        # ----------------------------------------------------------------------
        # Single source of truth for commit-time checks. Node-side tools run
        # via `pnpm exec` so prettier picks up `prettier-plugin-tailwindcss`
        # and cspell finds the project's `node_modules/@cspell/dict-*`.
        preCommitCheck = git-hooks-nix.lib.${system}.run {
          src = ./.;
          hooks = {
            check-added-large-files.enable = true;
            check-yaml.enable = true;
            # Preserve Markdown's two-trailing-space hard-break syntax.
            trim-trailing-whitespace = {
              enable = true;
              args = [ "--markdown-linebreak-ext=md" ];
            };

            nixfmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;

            # Mirrors the previous `lint-staged` config — same tools, same
            # globs, same on-disk effects (Prettier writes, others lint).
            prettier-write = {
              enable = true;
              name = "prettier";
              entry = nodeHook "prettier-write" "prettier --write --ignore-unknown";
              files = "\\.(css|js|json|md)$";
              pass_filenames = true;
            };

            markdownlint = {
              enable = true;
              name = "markdownlint-cli2";
              entry = nodeHook "markdownlint" "markdownlint-cli2";
              files = "\\.md$";
              pass_filenames = true;
            };

            cspell = {
              enable = true;
              entry = nodeHook "cspell" "cspell --no-must-find-files --no-progress";
              types = [ "text" ];
              pass_filenames = true;
            };
          };
        };
      in
      {
        # ----------------------------------------------------------------------
        # Dev Shell
        # ----------------------------------------------------------------------
        devShells.default = pkgs.mkShell {
          name = "hakula.xyz-kiln-dev";

          packages =
            preCommitCheck.enabledPackages
            ++ (with pkgs; [
              nodejs_22
              pnpm
              pagefind
            ]);

          # `pre-commit install` writes `.git/hooks/pre-commit` so direnv
          # users get the hook automatically. It backs up any prior hook
          # (e.g., from `git lfs install`) to `*.legacy` and chains it.
          inherit (preCommitCheck) shellHook;
        };

        # ----------------------------------------------------------------------
        # Checks (`nix flake check`)
        # ----------------------------------------------------------------------
        checks = {
          inherit preCommitCheck;
        };

        # ----------------------------------------------------------------------
        # Formatter (`nix fmt`)
        # ----------------------------------------------------------------------
        formatter = pkgs.nixfmt;
      }
    );
}
