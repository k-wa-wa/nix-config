{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    # Mac 用の適用コマンド: home-manager switch --flake .#macbook
    homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin; # Intel Macなら x86_64-darwin
      modules = [ ./hosts/macbook/home.nix ];
    };

    # Linux 用の適用コマンド: home-manager switch --flake .#ubuntu
    homeConfigurations."ubuntu" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./hosts/ubuntu/home.nix ];
    };
  };
}
