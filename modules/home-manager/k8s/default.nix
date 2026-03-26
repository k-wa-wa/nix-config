{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Kubernetes コアツール
    kubectl
    kubernetes-helm
    kind
    kustomize

    # クラスタ操作・可視化
    k9s
    kubectx
    kubecolor

    # ログ・デバッグ
    stern # 複数Podのログを同時に追跡
  ];

  programs.zsh.shellAliases = {
    k       = "kubecolor";
    klog    = "stern";
  };

  programs.zsh.initExtra = ''
    # kubectl completion を読み込んでから compdef でエイリアスを設定する
    source <(kubectl completion zsh)
    compdef kubecolor=kubectl
    compdef k=kubectl
  '';
}
