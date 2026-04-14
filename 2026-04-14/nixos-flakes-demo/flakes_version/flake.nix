{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.kehvatsu = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit pkgs-unstable inputs; };
        modules = [ ./configuration.nix ];
      };
    };
}
