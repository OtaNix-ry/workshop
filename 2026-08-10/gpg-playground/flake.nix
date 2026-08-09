{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: {
    devShells = builtins.mapAttrs (system: pkgs: {
      default = pkgs.mkShellNoCC {
        buildInputs = [
          pkgs.gnupg
          pkgs.pinentry-curses
        ];

        shellHook = ''
          alias gpg='gpg --pinentry-mode loopback'
        '';
      };
    }) inputs.nixpkgs.legacyPackages;
  };
}
