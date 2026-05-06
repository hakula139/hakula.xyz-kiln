# ==============================================================================
# hakula.xyz-kiln Site Development Flake
# ==============================================================================
#
# Provides Tailwind toolchain, kiln, pagefind, and pre-commit hooks. `kiln`
# (source-built) and `pagefind` (1.5+ prebuilt) come from kiln's flake.
#
#   nix develop        # interactive shell (auto-installs hooks)
#   nix flake check    # Nix-side hooks (Node-side run in CI's `check` job)

{
  description = "hakula.xyz-kiln — site source for hakula.xyz (dev environment)";

  # ----------------------------------------------------------------------------
  # Inputs
  # ----------------------------------------------------------------------------
  inputs = {
    # Nixpkgs - NixOS 25.11 stable release
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Per-system flake outputs
    flake-utils.url = "github:numtide/flake-utils";

    # kiln + pagefind (the kiln flake exposes both as `packages.${system}.*`).
    # Tracking feat/directive-template-config until merge — the comments-recent
    # directive needs the engine fix that exposes `config` to directive templates.
    kiln = {
      url = "github:hakula139/kiln/feat/directive-template-config";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # Pre-commit hooks
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  # ----------------------------------------------------------------------------
  # Outputs
  # ----------------------------------------------------------------------------
  outputs =
    {
      nixpkgs,
      flake-utils,
      kiln,
      git-hooks-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        kilnPkgs = kiln.packages.${system};

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
                pkgs.nodejs_24
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
            end-of-file-fixer.enable = true;
            # Preserve Markdown's two-trailing-space hard-break syntax.
            trim-trailing-whitespace = {
              enable = true;
              args = [ "--markdown-linebreak-ext=md" ];
            };

            nixfmt.enable = true;
            statix.enable = true;
            deadnix.enable = true;

            prettier-write = {
              enable = true;
              name = "prettier";
              entry = nodeHook "prettier-write" "prettier --write --ignore-unknown";
              files = "\\.(css|js|json)$";
              pass_filenames = true;
            };

            eslint = {
              enable = true;
              name = "eslint";
              entry = nodeHook "eslint" "eslint --fix";
              files = "\\.js$";
              pass_filenames = true;
            };

            markdownlint = {
              enable = true;
              name = "markdownlint-cli2";
              entry = nodeHook "markdownlint" "markdownlint-cli2 --fix";
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
            ++ [
              kilnPkgs.kiln
              kilnPkgs.pagefind
            ]
            ++ (with pkgs; [
              nodejs_24
              pnpm
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
          pre-commit = preCommitCheck;
        };

        # ----------------------------------------------------------------------
        # Formatter (`nix fmt`)
        # ----------------------------------------------------------------------
        formatter = pkgs.nixfmt;
      }
    );
}
