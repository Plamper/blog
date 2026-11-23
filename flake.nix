{
  description = "A flake for developing and building my personal blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tola.url = "github:tola-rs/tola-ssg";
  };

  outputs = { self, nixpkgs, flake-utils, tola }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tolaPkg = tola.packages.${system}.default;
      in
      {
        packages.tola = tolaPkg;
        packages.website = pkgs.stdenvNoCC.mkDerivation {
          pname = "plamper-blog";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ tolaPkg ];
          buildPhase = ''
            rm -rf public
            tola build --pure
          '';
          installPhase = ''
            cp -r public "$out"
          '';
        };
        packages.default = self.packages.${system}.website;
        devShells.default = pkgs.mkShell {
          packages = [
            tolaPkg
          ];
        };
      }
    );
}
