{
	description = "MathMage's dotfiles";
	
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager/release-24.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		musnix = { url = "github:musnix/musnix"; };
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, musnix, ... }:

	let
		system = "x86_64-linux";
		lib = nixpkgs.lib;
		pkgs = nixpkgs.legacyPackages.${system};
		pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
	in
	{
		nixosConfigurations = {
			nixos = lib.nixosSystem {
				inherit system;
				modules = [ 
					./configuration.nix
					musnix.nixosModules.musnix
				];
				specialArgs = {
					inherit pkgs-unstable;
					inherit musnix;
				};
			};
		};

		homeConfigurations = {
			damon = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;
				modules = [ ./home.nix ];
			};
		};
	};
}
