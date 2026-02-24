{
  description = "OtaNix ry typst-packages";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.systems.url = "github:nix-systems/default";
  outputs =
    {
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      overlays.default = _final: _prev: { };

      devShells = eachSystem (
        system:
        let
          rev = self.rev or "dirty";
          pkgs = nixpkgs.legacyPackages.${system};
          typst-font-paths = builtins.concatStringsSep ":" [
            "${pkgs.fira-sans}/share/fonts"
            "${pkgs.noto-fonts-emoji}/share/fonts"
          ];
          typst-watch = pkgs.writeShellScriptBin "typst-watch" ''
            ${pkgs.typst}/bin/typst watch --input rev=${rev} "$@"
          '';
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              typst
              typst-watch
              fira-sans
              noto-fonts-emoji
            ];
            TYPST_FONT_PATHS = typst-font-paths;
          };
        }
      );

      # templates = rec {
      #   default = quick-start;
      #   quick-start = {
      #     description = "OtaNix typst example";
      #     path = ./examples/quick-start;
      #   };
      # };
    };
}
