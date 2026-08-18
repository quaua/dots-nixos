{
    description = "I have no fucking idea what i wrote down there.";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs"; # force to use already set nixpkgs branch
        };
        awww.url = "git+https://codeberg.org/LGFae/awww";
        matugen = {
            url = "github:/InioX/Matugen";
        };
        spicetify-nix.url = "github:Gerg-L/spicetify-nix";
        zen-browser = {
            url = "github:youwen5/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        quickshell = {
            url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        qml-niri = {
            url = "github:imiric/qml-niri/main";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.quickshell.follows = "quickshell";
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
                            extraSpecialArgs = { inherit inputs; };
                            users.jaga = import ./home.nix;
                        };
                    }
            ];
        };
    };
}
