{
  description = "My own very first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # force to use already set nixpkgs branch
    };
    awww.url = "git+https://codeberg.org/LGFae/awww";
    matugen = {
      url = "github:/InioX/Matugen";
      # If you need a specific version:
      #ref = "refs/tags/matugen-v0.10.0";
    };
  };

  outputs = { nixpkgs, home-manager, self, ... } @ inputs: {
    nixosConfigurations.reaper = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
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
