{
  description = "Nix flake for kernel development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        kernel = pkgs.linux_6_12.override {
          stdenv = pkgs.llvmPackages.stdenv;
        };
      in
      {
        devShell = pkgs.mkShell.override { stdenv = pkgs.llvmPackages.stdenv; } {
          MAKEFLAGS = kernel.commonMakeFlags;
          LLVM = 1;
          packages =
            with pkgs;
            [
              bear
              b4
              clang-tools
              ncurses
            ]
            ++ kernel.nativeBuildInputs;
        };
      }
    );
}
