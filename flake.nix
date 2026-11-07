# ==================================================================================================
# hakula.xyz-kiln Site Development Flake
# ==================================================================================================

{
  description = "hakula.xyz site development environment";

  # ------------------------------------------------------------------------------------------------
  # Inputs
  # ------------------------------------------------------------------------------------------------
  inputs = {
    # Following kiln's nixpkgs keeps the kiln package identical to its Cachix build.
    nixpkgs.follows = "kiln/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    kiln = {
      url = "github:hakula139/kiln/v0.5.2";
      inputs = {
        flake-utils.follows = "flake-utils";
        git-hooks-nix.follows = "devkit/git-hooks-nix";
        kiln-tailwindcss.inputs.git-hooks-nix.follows = "devkit/git-hooks-nix";
      };
    };

    devkit = {
      url = "github:hakula139/devkit/v1.0.0-rc.3";
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
      devkit,
      ...
    }:
    flake-utils.lib.eachSystem (builtins.attrNames kiln.packages) (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dk = devkit.lib.mkLib pkgs;

        # ------------------------------------------------------------------------------------------
        # Pre-commit Hooks
        # ------------------------------------------------------------------------------------------
        # These hooks run the tools pinned in node_modules, which the Nix sandbox lacks. The flake
        # check leaves them to CI's Site Check job.
        nodeHook =
          name: cmd:
          pkgs.lib.getExe (
            pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = with pkgs; [
                nodejs_26
                pnpm
              ];
              text = ''
                if [ ! -d node_modules ]; then
                  echo "node_modules is missing. Run pnpm install --frozen-lockfile, then commit again." >&2
                  exit 1
                fi
                pnpm exec ${cmd} "$@"
              '';
            }
          );

        nodeHooks = {
          cspell = {
            enable = true;
            package = null;
            entry = nodeHook "cspell" "cspell --no-must-find-files --no-progress";
            types = [ "text" ];
          };
          prettier = {
            enable = true;
            package = null;
            entry = nodeHook "prettier" "prettier --write --ignore-unknown";
            files = "\\.(css|js|mjs|json|jsonc|ya?ml|md)$";
            types = [ "text" ];
          };
          eslint = {
            enable = true;
            package = null;
            entry = nodeHook "eslint" "eslint --fix";
            files = "\\.(js|mjs)$";
          };
        };

        preCommit = dk.preCommit {
          src = ./.;
          hooks = {
            dprint.enable = false;
            ruff.enable = true;
            ruff-format.enable = true;
          };
          devHooks = nodeHooks;
        };

        titleFonts = pkgs.google-fonts.override {
          fonts = [ "Shippori Mincho" ];
        };
      in
      {
        # ------------------------------------------------------------------------------------------
        # Dev Shell
        # ------------------------------------------------------------------------------------------
        devShells.default = pkgs.mkShell {
          name = "hakula.xyz-kiln-dev";

          inputsFrom = [ preCommit.shell ];

          packages = [
            kiln.packages.${system}.kiln
          ]
          ++ (with pkgs; [
            fontconfig
            nodejs_26
            pnpm
            (python314.withPackages (ps: [ ps.pillow ]))
          ]);

          FONTCONFIG_FILE = pkgs.makeFontsConf {
            fontDirectories = [
              "${pkgs.sarasa-gothic}/share/fonts"
              "${titleFonts}/share/fonts"
            ];
          };
        };

        # ------------------------------------------------------------------------------------------
        # Checks
        # ------------------------------------------------------------------------------------------
        checks.pre-commit = preCommit.check;

        # ------------------------------------------------------------------------------------------
        # Formatter
        # ------------------------------------------------------------------------------------------
        formatter = pkgs.nixfmt-tree;
      }
    );
}
