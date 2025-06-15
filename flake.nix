{
  nixConfig.allow-import-from-derivation = false;

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;

      collectInputs =
        is:
        pkgs.linkFarm "inputs" (
          builtins.mapAttrs (
            name: i:
            pkgs.linkFarm name {
              self = i.outPath;
              deps = collectInputs (lib.attrByPath [ "inputs" ] { } i);
            }
          ) is
        );

      overlays.default = (final: _: import ./default.nix { pkgs = final; });

      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        overlays = [ overlays.default ];
      };

      formatter = treefmtEval.config.build.wrapper;

      packages = {
        default = pkgs.nix-debug;
        nix-debug = pkgs.nix-debug;
        formatting = treefmtEval.config.build.check self;
        formatter = formatter;
        allInputs = collectInputs inputs;
      };

      gcroot = packages // {
        gcroot = pkgs.linkFarm "gcroot" packages;
      };

      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        programs.prettier.enable = true;
        programs.shfmt.enable = true;
        programs.shellcheck.enable = true;
        settings.formatter.shellcheck.options = [
          "-s"
          "sh"
        ];
        settings.global.excludes = [ "LICENSE" ];
      };

    in

    {

      overlays = overlays;

      packages.x86_64-linux = gcroot;

      checks.x86_64-linux = gcroot;

      formatter.x86_64-linux = formatter;

    };
}
