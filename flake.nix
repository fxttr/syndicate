{
  description = "The syndicate bootloader";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    packages.x86_64-linux.syndicate =
      let pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
      in pkgs.stdenv.mkDerivation {
        pname = "syndicate";
        version = "0.0.1";
        src = ./.;

        nativeBuildInputs = with pkgs; [
          gnumake
          nasm
        ];
      };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.syndicate;
  };
}
