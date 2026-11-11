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
      url = "github:hakula139/devkit/v3";
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
        preCommit = dk.preCommit {
          src = ./.;
          hooks = {
            cspell.package = dk.nodeTool "cspell";
            eslint.enable = true;
            markdownlint-cli2.settings.configPath = ".markdownlint-cli2.jsonc";
            prettier = {
              enable = true;
              package = dk.nodeTool "prettier";
              files = "\\.(css|js|mjs|json|jsonc|ya?ml)$";
            };
            ruff.enable = true;
            ruff-format.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
            taplo.enable = true;
          };
        };
      in
      {
        # ------------------------------------------------------------------------------------------
        # Dev Shell
        # ------------------------------------------------------------------------------------------
        devShells.default =
          let
            titleFonts = pkgs.google-fonts.override {
              fonts = [ "Shippori Mincho" ];
            };
          in
          pkgs.mkShell {
            name = "hakula.xyz-kiln-dev";

            inputsFrom = [ preCommit ];

            packages = [
              kiln.packages.${system}.kiln
            ]
            ++ builtins.attrValues dk.nodeToolchain
            ++ (with pkgs; [
              fontconfig
              (python314.withPackages (ps: [ ps.pillow ]))
            ]);

            # devkit's nix.yml checks out without submodules, and the Prettier
            # Tailwind plugin needs the theme stylesheet that the site imports.
            shellHook = ''
              if [ ! -e themes/IgnIt/assets ] &&
                git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                git submodule update --init themes/IgnIt >&2
              fi
            '';

            FONTCONFIG_FILE = pkgs.makeFontsConf {
              fontDirectories = [
                "${pkgs.sarasa-gothic}/share/fonts"
                "${titleFonts}/share/fonts"
              ];
            };
          };

        # ------------------------------------------------------------------------------------------
        # Formatter
        # ------------------------------------------------------------------------------------------
        formatter = pkgs.nixfmt-tree;
      }
    );
}
