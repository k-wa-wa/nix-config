{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Kubernetes コアツール
    kubectl
    kubernetes-helm
    kind             # ローカルKubernetesクラスタ（Docker in Docker）
    kustomize        # YAMLのオーバーレイ管理

    # クラスタ操作・可視化
    k9s              # TUIでKubernetesを操作できる便利ツール
    kubectx          # コンテキスト/ネームスペース切り替えを楽にするツール（kubensも含む）
    kubecolor        # kubectlの出力をカラー表示

    # ログ・デバッグ
    stern            # 複数Podのログを同時に追跡
  ];

  programs.zsh.shellAliases = {
    k       = "kubecolor";
    klog    = "stern";
  };

  programs.zsh.initContent = ''
    # kubectl completion を読み込んでから compdef でエイリアスを設定する
    source <(kubectl completion zsh)
    compdef kubecolor=kubectl
    compdef k=kubectl
  '';
}
