{
  inputs.self.submodules = true;
  # pinning nixpkgs for old cmake and gcc
  inputs.nixpkgs-old.url = "github:NixOS/nixpkgs/f4b140d5b253f5e2a1ff4e5506edbf8267724bde";
  outputs = inputs@{
    self, nixpkgs, nixpkgs-old, flake-parts,
  }: let
    ecc-dreamplace = {
      lib,
      stdenv,
      python3Packages,
      cmake,
      ninja,
      zlib,
      boost,
      bison,
      flex,
    }: python3Packages.buildPythonPackage.override { inherit stdenv; } rec {
      name = "dreamplace";
      format = "pyproject";

      src = with lib.fileset; toSource {
        root = ./.;
        fileset = unions [
          ./thirdparty
          ./dreamplace
          ./unittest
          ./benchmarks
          ./test
          ./cmake
          ./CMakeLists.txt
          ./pyproject.toml
          ./uv.lock
        ];
      };

      build-system = [
        python3Packages.scikit-build-core
      ];

      dependencies = with python3Packages; [
        cairocffi
        distutils
        matplotlib
        numpy
        patool
        pkgconfig
        scipy
        setuptools
        shapely
        torch
        wheel
      ];

      buildInputs = [ zlib boost flex ];
      nativeBuildInputs = [ bison flex cmake ninja ];

      dontUseCmakeConfigure = true;
      dontCheckRuntimeDeps = true;

      pythonImportsCheck = [
        "dreamplace"
        "dreamplace.Params"
      ];

      passthru.rawBuildInputs = buildInputs;
      passthru.rawNativeBuildInputs = nativeBuildInputs;
    };
  in flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    perSystem = { self', pkgs, system, ... }: {
      packages.default = pkgs.callPackage ecc-dreamplace {
        inherit (nixpkgs-old.legacyPackages.${system}) cmake stdenv;
      };
      devShells.default = pkgs.mkShell.override {
        inherit (nixpkgs-old.legacyPackages.${system}) stdenv;
      } {
        buildInputs = self'.packages.default.rawBuildInputs;
        nativeBuildInputs = self'.packages.default.rawNativeBuildInputs ++ (with pkgs; [ uv ]);
      };
    };
  };
}
