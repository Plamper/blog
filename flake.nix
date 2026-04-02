{
  description = "A flake for developing and building my personal blog";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            zola
          ];
        };
      }
    );
}
