# ==================================================================================================
# hakula.xyz-kiln Site Development Flake
# ==================================================================================================
#
# Provides kiln and pre-commit hooks. kiln's package carries its CSS compiler
# and Pagefind on its own PATH.
#
#   nix develop        # interactive shell (auto-installs hooks)
#   nix flake check    # Nix-side hooks (Node-side run in CI's `check` job)

{
  description = "hakula.xyz-kiln — site source for hakula.xyz (dev environment)";

  # ------------------------------------------------------------------------------------------------
  # Inputs
  # ------------------------------------------------------------------------------------------------
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

  # ------------------------------------------------------------------------------------------------
  # Outputs
  # ------------------------------------------------------------------------------------------------
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

        # ------------------------------------------------------------------------------------------
        # Pre-commit Hooks
        # ------------------------------------------------------------------------------------------
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
        };

        # These hooks run the tools pinned in node_modules, which the Nix sandbox lacks. The flake
        # check leaves them to CI's Site Check job.
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
                  echo "node_modules is missing. Run pnpm install --frozen-lockfile, then commit again." >&2
                  exit 1
                fi
                pnpm exec ${cmd} "$@"
              '';
            };
          in
          "${wrapper}/bin/${name}";

        nodeHooks = {
          prettier-write = {
            enable = true;
            name = "prettier";
            entry = nodeHook "prettier-write" "prettier --write --ignore-unknown";
            types = [ "text" ];
          };
          taplo-write = {
            enable = true;
            name = "taplo";
            entry = nodeHook "taplo-write" "taplo format";
            files = "\\.toml$";
          };

          cspell = {
            enable = true;
            package = null;
            entry = nodeHook "cspell" "cspell --no-must-find-files --no-progress";
            types = [ "text" ];
          };
          eslint = {
            enable = true;
            package = null;
            entry = nodeHook "eslint" "eslint --fix";
            files = "\\.(js|mjs)$";
          };
          markdownlint = {
            enable = true;
            package = null;
            name = "markdownlint-cli2";
            entry = nodeHook "markdownlint" "markdownlint-cli2 --fix";
            files = "\\.md$";
          };
        };

        preCommit = git-hooks-nix.lib.${system}.run {
          src = ./.;
          hooks = hooks // nodeHooks;
        };

        preCommitCheck = git-hooks-nix.lib.${system}.run {
          inherit hooks;
          src = ./.;
        };

        flock = pkgs.lib.getExe pkgs.flock;
        git = pkgs.lib.getExe pkgs.git;
      in
      {
        # ------------------------------------------------------------------------------------------
        # Dev Shell
        # ------------------------------------------------------------------------------------------
        devShells.default = pkgs.mkShell {
          name = "hakula.xyz-kiln-dev";

          packages = [
            preCommit.config.package
          ]
          ++ preCommit.enabledPackages
          ++ [
            kiln.packages.${system}.kiln
          ]
          ++ (with pkgs; [
            nodejs_24
            pnpm
          ]);

          # git-hooks.nix stores a relative hooks path that linked worktrees can't resolve
          # (cachix/git-hooks.nix#688). Unset it to use Git's shared hooks directory. The lock keeps
          # another shell from setting it mid-install, which pre-commit refuses.
          shellHook = ''
            if common=$(${git} rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
              (
                ${flock} 9
                ${preCommit.config.installationScript}
                ${git} config --local --unset-all core.hooksPath || true
              ) 9>"$common/git-hooks.lock"
            fi
          '';
        };

        # ------------------------------------------------------------------------------------------
        # Checks (`nix flake check`)
        # ------------------------------------------------------------------------------------------
        checks = {
          pre-commit = preCommitCheck;
        };

        # ------------------------------------------------------------------------------------------
        # Formatter (`nix fmt`)
        # ------------------------------------------------------------------------------------------
        formatter = pkgs.nixfmt-tree;
      }
    );
}
