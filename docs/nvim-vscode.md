# VSCode → Neovim 体験の変化

## 基本的な考え方の違い

| | VSCode | Neovim |
|---|---|---|
| 操作スタイル | マウス + キーボード | キーボードのみ |
| モード | 常に入力モード | Normal / Insert / Visual モードの切り替え |
| 設定 | GUI + settings.json | Nix (neovim.nix) |
| 拡張機能 | Marketplace から install | Nix で宣言的に管理 |

Neovim は **Normal モード** (テキスト移動・操作) と **Insert モード** (文字入力) を切り替えながら使う。
`i` で Insert 入力開始、`<Esc>` で Normal に戻る。

---

## 機能対応表

### ファイル操作

| VSCode | Neovim | キー |
|---|---|---|
| Ctrl+P (Quick Open) | Telescope ファイル検索 | `<leader>ff` |
| Ctrl+Shift+F (全文検索) | Telescope live grep | `<leader>fg` |
| エクスプローラーパネル | Neo-tree | `<leader>e` (toggle) / `<leader>o` (focus) |
| エクスプローラー → エディタに戻る | ペイン移動 | `<C-l>` |

### 編集

| VSCode | Neovim | キー |
|---|---|---|
| Ctrl+/ (コメントアウト) | `gc` (行単位) / `gcc` (1行) | 組み込み |
| 括弧の自動補完 | nvim-autopairs | 自動 |
| Ctrl+Space (補完) | nvim-cmp (自動表示) | `<C-Space>` で手動トリガー |
| Tab で補完確定 | `<Tab>` / `<CR>` | どちらでも可 |

### LSP (IntelliSense 相当)

| VSCode | Neovim | キー |
|---|---|---|
| 定義へ移動 (F12) | Go to Definition | `gd` |
| 宣言へ移動 | Go to Declaration | `gD` |
| 参照一覧 | References | `gr` |
| 実装へ移動 | Go to Implementation | `gi` |
| ホバードキュメント | Hover Docs | `K` |
| リネーム (F2) | Rename Symbol | `<leader>rn` |
| クイックフィックス | Code Action | `<leader>ca` |
| フォーマット | Format | `<leader>lf` |
| エラー一覧 | Telescope diagnostics | `<leader>fd` |
| エラーの詳細表示 | Diagnostic float | `<leader>d` |
| 次のエラーへ | Next diagnostic | `]d` |
| 前のエラーへ | Prev diagnostic | `[d` |

対応言語: **Go / TypeScript / JavaScript / Lua / Nix / YAML / Python**

### タブ / ウィンドウ

| VSCode | Neovim | キー |
|---|---|---|
| タブ切り替え (Ctrl+Tab) | バッファ移動 | `<S-h>` / `<S-l>` |
| タブを閉じる | バッファ削除 | `<leader>bd` |
| エディタ分割 | `:vsplit` / `:split` | コマンドで分割 |
| 分割ウィンドウ間移動 | ペイン移動 | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` |

### Git

| VSCode | Neovim | キー |
|---|---|---|
| ソース管理パネル (diff 表示) | Diffview open | `<leader>gs` |
| Diffview を閉じる | Diffview close | `<leader>gc` |
| 現在ファイルの git 履歴 | File history (current) | `<leader>gh` |
| リポジトリ全体の git 履歴 | File history (repo) | `<leader>gH` |
| 行の blame 表示 | Git blame | `<leader>gb` |
| 変更箇所の diff | Git diff (hunk) | `<leader>gd` |
| hunk のプレビュー | Preview hunk | `<leader>gp` |
| 次の変更箇所へ | Next hunk | `]h` |
| 前の変更箇所へ | Prev hunk | `[h` |
| ガター (変更サイン) | gitsigns | 自動表示 |

---

## キーマップのヒント

`<Space>` を押すと **which-key** が起動し、利用可能なキーマップの一覧が表示される。
`<leader>` = `<Space>`

---

## 最初に慣れが必要なこと

1. **モード切り替え** — 常に `<Esc>` で Normal に戻る意識
2. **マウスを使わない** — 移動・選択・操作をすべてキーで行う
3. **`hjkl` 移動** — 矢印キーの代わりに `h`(左) `j`(下) `k`(上) `l`(右)
4. **保存** — `<leader>w` または `:w<CR>`

---

## VSCode より優れる点

- キーボードだけで完結するため操作が速い
- 設定が Nix で宣言的に管理され、環境の再現性が高い
- ターミナルとの親和性が高い (tmux との組み合わせが強力)
- リソース消費が少ない
