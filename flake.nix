{
  # pinning nixpkgs for old cmake
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/f4b140d5b253f5e2a1ff4e5506edbf8267724bde";
  outputs = inputs@{
    self, nixpkgs, flake-parts,
  }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    perSystem = { pkgs, ... }: {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          zlib boost
        ];
        nativeBuildInputs = with pkgs; [
          cmake bison flex uv
        ];
      };
    };
  };
}
