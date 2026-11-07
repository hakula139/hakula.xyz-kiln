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
      url = "github:hakula139/devkit/e0d835ba91cf38c7f6d950c8a56c0d68e74366bd";
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
        nodeHooks = {
          cspell = {
            enable = true;
            package = null;
            entry = "${pkgs.lib.getExe (dk.nodeTool "cspell")} --no-must-find-files --no-progress";
            types = [ "text" ];
          };
          prettier = {
            enable = true;
            package = null;
            entry = "${pkgs.lib.getExe (dk.nodeTool "prettier")} --write --ignore-unknown";
            files = "\\.(css|js|mjs|json|jsonc|ya?ml|md)$";
            types = [ "text" ];
          };
          eslint = {
            enable = true;
            package = null;
            entry = "${pkgs.lib.getExe (dk.nodeTool "eslint")} --fix";
            files = "\\.(js|mjs)$";
          };
        };

        preCommit = dk.preCommit {
          src = ./.;
          hooks = {
            actionlint.enable = true;
            check-yaml.enable = true;
            deadnix.enable = true;
            dprint.enable = false;
            editorconfig-checker.enable = true;
            markdownlint-cli2.enable = true;
            nixfmt.enable = true;
            ruff.enable = true;
            ruff-format.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
            sort-file-contents.enable = true;
            statix.enable = true;
            taplo.enable = true;
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
