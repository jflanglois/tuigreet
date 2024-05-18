{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.rustPlatform.buildRustPackage {
      pname = "tuigreet";
      version = "0.9.0";
      src = ./.;
      cargoLock.lockFile = ./Cargo.lock;
    };
    devShells.x86_64-linux.default =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in self.packages.x86_64-linux.default.overrideAttrs(old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.rust-analyzer ];
      });
    overlays.default = final: prev: {
      greetd = prev.greetd // {
        tuigreet = self.packages.x86_64-linux.default;
      };
    };
  };
}
