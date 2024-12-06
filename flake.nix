{
  description = "le flake de awesome!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ 
    self, 
    nixpkgs, 
    nixpkgs-unstable, 
    ... 
  }: {
    nixosConfigurations = {
      gamebeast = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ ./hosts/gamebeast/configuration.nix ];
        specialArgs = {
          nixpkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
    };
  };
}
