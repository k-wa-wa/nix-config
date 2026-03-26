{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }: 
    let
      system = "aarch64-darwin"; # Intel Macなら x86_64-darwin
      pkgs = nixpkgs.legacyPackages.${system};
      unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
    in {
    # Mac 用の適用コマンド: home-manager switch --flake .#macbook
    homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit unstablePkgs; };
      modules = [ ./hosts/macbook/home.nix ];
    };

    # Mac2 用の適用コマンド: home-manager switch --flake .#mac2
    homeConfigurations."mac2" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit unstablePkgs; };
      modules = [ ./hosts/mac2/home.nix ];
    };
  };
}
