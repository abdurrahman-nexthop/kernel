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
        stdenv = pkgs.llvmPackages.stdenv;
        kernel = pkgs.linux_7_1.override { inherit stdenv; };
      in
      {
        devShell = pkgs.mkShell.override { inherit stdenv; } {
          MAKEFLAGS = kernel.commonMakeFlags;
          LLVM = 1;
          HOSTLDFLAGS = "-Wl,-rpath,${pkgs.openssl.out}/lib";
          packages =
            with pkgs;
            [
              bear
              b4
              clang-tools
              gitFull
              lld
              ncurses
              openssl
              pkg-config
            ]
            ++ (with python3Packages; [
              dtschema
              gitpython
              ply
              yamllint
            ])
            ++ kernel.nativeBuildInputs;
        };
      }
    );
}
