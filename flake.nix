{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: 
    let
      system = "aarch64-darwin"; # Intel Macなら x86_64-darwin
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    # Mac 用の適用コマンド: home-manager switch --flake .#macbook
    homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./hosts/macbook/home.nix ];
    };

    # Mac2 用の適用コマンド: home-manager switch --flake .#mac2
    homeConfigurations."mac2" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./hosts/mac2/home.nix ];
    };

    # atelier (nuage-cluster) の nixos ユーザーの環境。nuage-cluster が home-manager の NixOS モジュールとして読み込む。
    homeModules.atelier = ./hosts/atelier/home.nix;

    # どのホストのエージェントにも効く個人の共通ルール。atelier では nuage-cluster が autopilot5 の共通ルールに足す。
    lib.agentRules = ./modules/home-manager/ai-agent/rules.md;
  };
}
