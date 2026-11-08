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

    kiln = {
      url = "github:hakula139/kiln/v0.5.2";
      inputs = {
        git-hooks-nix.follows = "devkit/git-hooks-nix";
        kiln-tailwindcss.inputs.git-hooks-nix.follows = "devkit/git-hooks-nix";
      };
    };

    devkit = {
      url = "github:hakula139/devkit/v1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ------------------------------------------------------------------------------------------------
  # Outputs
  # ------------------------------------------------------------------------------------------------
  outputs =
    {
      nixpkgs,
      kiln,
      devkit,
      ...
    }:
    devkit.lib.eachSystem (builtins.attrNames kiln.packages) (
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
            package = dk.nodeTool "cspell";
            types = [ "text" ];
          };
          prettier = {
            enable = true;
            package = dk.nodeTool "prettier";
            files = "\\.(css|js|mjs|json|jsonc|ya?ml)$";
            types = [ "text" ];
          };
          eslint = {
            enable = true;
            package = dk.nodeTool "eslint";
            files = "\\.(js|mjs)$";
          };
        };

        preCommit = dk.preCommit {
          src = ./.;
          hooks = {
            actionlint.enable = true;
            check-yaml.enable = true;
            deadnix.enable = true;
            dprint.enable = true;
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
            pnpm_12
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
