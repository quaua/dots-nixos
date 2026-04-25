{
  description = "My own very first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # force to use already set nixpkgs branch
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.reaper = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
	home-manager.nixosModules.home-manager
	{
          home-manager = {
 	    useGlobalPkgs = true;
	    useUserPackages = true;
	    users.jaga = import ./home.nix;
	  };
	}
      ];
    };
  };
}
