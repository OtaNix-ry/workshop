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
          export PS1='\n\[\033[1;32m\][\[\e]0;$(gpg -K --with-colons 2>/dev/null | awk -F: '"'"'$1=="uid"{print $10; exit}'"'"'): \w\a\]$(gpg -K --with-colons 2>/dev/null | awk -F: '"'"'$1=="uid"{print $10; exit}'"'"'):\w]\$\[\033[0m\] '
        '';
      };
    }) inputs.nixpkgs.legacyPackages;
  };
}
