{
  description = "Nixboutique - a modern GTK4 browser and manager for NixOS applications";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = eachSystem (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          pname = "nixboutique";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.meson pkgs.ninja pkgs.pkg-config pkgs.vala ];
          buildInputs = [ pkgs.gtk4 pkgs.json-glib pkgs.libgee ];
          installPhase = "mkdir -p $out/bin; cp nixboutique $out/bin/";
        };
      });
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.meson pkgs.ninja pkgs.pkg-config pkgs.vala pkgs.gtk4 pkgs.json-glib pkgs.libgee ];
        };
      });
    };
}
