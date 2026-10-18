# ==============================================================================
# hakula.xyz-kiln Site Development Flake
# ==============================================================================
#
# Provides kiln and pre-commit hooks. kiln's package carries its CSS compiler
# and Pagefind on its own PATH.
#
#   nix develop        # interactive shell (auto-installs hooks)
#   nix flake check    # Nix-side hooks (Node-side run in CI's `check` job)

{
  description = "hakula.xyz-kiln — site source for hakula.xyz (dev environment)";

  # ----------------------------------------------------------------------------
  # Inputs
  # ----------------------------------------------------------------------------
  inputs = {
    # Following kiln's nixpkgs keeps the kiln package identical to its Cachix build.
    nixpkgs.follows = "kiln/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    kiln = {
      url = "github:hakula139/kiln/v0.5.0";
      inputs = {
        flake-utils.follows = "flake-utils";
        git-hooks-nix.follows = "git-hooks-nix";
        kiln-tailwindcss.inputs.git-hooks-nix.follows = "git-hooks-nix";
      };
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    flake-utils.lib.eachSystem (builtins.attrNames kiln.packages) (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # ----------------------------------------------------------------------
        # Node Hook Wrapper
        # ----------------------------------------------------------------------
        # Node hooks need the local dependencies, which the Nix sandbox excludes.
        # CI runs the equivalent checks directly with pnpm.
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
              files = "\\.(css|js|mjs|json|md|ya?ml)$";
              pass_filenames = true;
            };

            eslint = {
              enable = true;
              package = null;
              name = "eslint";
              entry = nodeHook "eslint" "eslint --fix";
              files = "\\.(js|mjs)$";
              pass_filenames = true;
            };

            markdownlint = {
              enable = true;
              package = null;
              name = "markdownlint-cli2";
              entry = nodeHook "markdownlint" "markdownlint-cli2 --fix";
              files = "\\.md$";
              pass_filenames = true;
            };

            cspell = {
              enable = true;
              package = null;
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
              kiln.packages.${system}.kiln
            ]
            ++ (with pkgs; [
              nodejs_24
              pnpm
            ]);

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
        formatter = pkgs.nixfmt-tree;
      }
    );
}
