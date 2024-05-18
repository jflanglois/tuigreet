{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs";
    rust-flake.url = "github:juspay/rust-flake";
  };
  outputs = inputs@{ flake-parts, rust-flake, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ 
        rust-flake.flakeModules.default
        rust-flake.flakeModules.nixpkgs
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      perSystem = { config, self', pkgs, lib, ... }: {
        rust-project.crates.tuigreet.crane.extraBuildArgs = {
          src = let
            craneLib = config.rust-project.crane-lib;
            # This is needed to include fluent i18n files. See https://crane.dev/source-filtering.html.
            srcFilter = path: type: craneLib.filterCargoSources path type || builtins.match ".*\\.ftl$" path != null;
          in lib.cleanSourceWith {
            src = ./.;
            filter = srcFilter;
            name = "source";
          };
        };
        packages.default = self'.packages.tuigreet;
        devShells.default = self'.devShells.rust;
      };
  };
}
