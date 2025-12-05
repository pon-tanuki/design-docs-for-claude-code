# 設計書テンプレート for Claude Code

LLM（特にClaude Code）による効率的なドキュメント作成を支援するMarkdownテンプレート集です。

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Templates](https://img.shields.io/badge/templates-28-green.svg)
![Language](https://img.shields.io/badge/language-Japanese-red.svg)

## 📋 目次

- [概要](#概要)
- [主な機能](#主な機能)
- [デモ](#デモ)
- [クイックスタート](#クイックスタート)
- [使い方](#使い方)
- [テンプレート一覧](#テンプレート一覧)
- [特徴](#特徴)
- [Claude Code設定](#claude-code設定)
- [ディレクトリ構成](#ディレクトリ構成)
- [よくある質問](#よくある質問)
- [トラブルシューティング](#トラブルシューティング)
- [貢献](#貢献)
- [ライセンス](#ライセンス)

## 概要

このプロジェクトは、小規模プロジェクト（フリーランス・副業案件など）向けに最適化された、包括的な設計書テンプレート集を提供します。

### 背景

ソフトウェア開発において、適切なドキュメント作成は重要ですが、小規模プロジェクトでは過度に複雑なドキュメントは負担になります。また、LLM時代において、LLMが効率的に編集・更新できるフォーマットが求められています。

### 目的

- LLM（Claude Code等）で効率的に編集可能なテンプレート提供
- 小規模プロジェクトに最適化された実践的な内容
- コピペですぐ使える実装例の提供
- Mermaid図による視覚化
- Git管理に適したMarkdown形式

## 主な機能

- ✨ **28種類のテンプレート**: 企画から運用まで全フェーズをカバー
- 🤖 **Claude Code最適化**: カスタムコマンドで効率的な編集
- 📊 **Mermaid図対応**: アーキテクチャ図、ER図、シーケンス図など
- 💻 **実践的コード例**: TypeScript/JavaScript中心の動作するサンプル
- 🚀 **ワンライナーセットアップ**: curlコマンド1つで導入可能
- 📝 **日本語完備**: すべてのドキュメントが日本語

## デモ

**リポジトリ**: https://github.com/pon-tanuki/design-docs-for-claude-code

**セットアップデモ**:
```bash
# テンプレート + Claude Code設定を一度にセットアップ
SETUP_CLAUDE=yes curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
```

## クイックスタート

### 方法1: すべて一度に（推奨）

```bash
SETUP_CLAUDE=yes curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
```

テンプレート + Claude Code設定を同時にセットアップ

### 方法2: テンプレートのみ

```bash
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
```

### 方法3: インタラクティブセットアップ

```bash
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/setup-docs.sh | bash
```

対話形式でディレクトリ名やフェーズを選択できます。

### 環境変数でカスタマイズ

```bash
# ドキュメントディレクトリを"documents"に、計画フェーズのみダウンロード
DOCS_DIR=documents PHASE=planning SETUP_CLAUDE=yes curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
```

**環境変数**:
- `DOCS_DIR`: ドキュメントディレクトリ名（デフォルト: `docs`）
- `PHASE`: ダウンロードするフェーズ（デフォルト: `all`）
  - `all`: すべて
  - `planning`, `design`, `development`, `testing`, `operation`, `common`
- `SETUP_CLAUDE`: Claude Code設定もセットアップ（デフォルト: `no`）
  - `yes`, `y`, `true`: セットアップする

## 使い方

### 1. テンプレートのセットアップ

上記のクイックスタートでテンプレートをダウンロードします。

### 2. Claude Code でドキュメントを作成

```bash
# Claude Code を起動
claude

# プロンプト例:
# "docs/01_planning/project_overview.md を、
#  ECサイト構築プロジェクトの内容で埋めてください。
#  予算は50万円、納期は3ヶ月です。"
```

### 3. 継続的な更新

要件変更や設計変更があった際も、Claude Code に依頼するだけで関連ドキュメントを更新できます。

```bash
# 例:
# "決済方法にPayPalを追加したので、
#  関連するドキュメントを更新してください"
```

### 4. Claude Code カスタムコマンド（推奨）

Claude Code設定をセットアップすると、以下のコマンドが使えます：

```bash
# 新規ドキュメント作成
/new-phase-doc planning project_overview

# ドキュメント更新（メタデータ自動更新）
/update-doc docs/01_planning/project_overview.md 予算を100万円に変更

# 品質チェック
/check-doc docs/01_planning/project_overview.md
```

詳細は [examples/README.md](./examples/README.md) を参照してください。

## テンプレート一覧

### 📋 計画フェーズ (01_planning)
- **プロジェクト概要書**: 見積もり、契約条件、納品物
- **要件定義書**: 機能要件、非機能要件、制約事項
- **ユースケース記述書**: ユーザーシナリオ、画面遷移

### 🎨 設計フェーズ (02_design)
- **システム設計書**: アーキテクチャ、技術スタック、インフラ
- **データベース設計書**: ERD、テーブル定義、マイグレーション
- **API仕様書**: エンドポイント、リクエスト/レスポンス
- **画面設計書**: デザインシステム、UIコンポーネント

### 💻 開発フェーズ (03_development)
- **コーディング規約**: 命名規則、スタイルガイド
- **開発環境構築手順**: セットアップ、トラブルシューティング
- **技術仕様書**: 実装詳細、アルゴリズム

### 🧪 テストフェーズ (04_testing)
- **テスト計画書**: テスト戦略、スケジュール
- **テストケース仕様書**: 詳細なテスト手順
- **テスト報告書**: 結果サマリー、バグレポート

### ⚙️ 運用フェーズ (05_operation)
- **運用手順書**: デプロイ、監視、バックアップ
- **障害対応手順書**: インシデント対応フロー
- **保守・メンテナンス計画書**: 定期作業、SLA

### 📚 共通ドキュメント (06_common)
- **ドキュメント共通フォーマット**: 記述ルール
- **README/CHANGELOG テンプレート**: プロジェクト文書
- **ADR テンプレート**: アーキテクチャ決定記録
- **セキュリティ設計書**: OWASP Top 10 対策
- **パフォーマンス設計書**: Core Web Vitals、最適化

## 特徴

### ✅ 小規模プロジェクト向けに最適化
- フリーランス・小規模チーム（1-3人）での使用を想定
- 過度に複雑な企業向けプロセスを排除
- 実践的で即座に使える内容

### 💡 実践的なコード例
- TypeScript/JavaScript のコード例が豊富
- コピペですぐ使える実装サンプル
- 現実的な技術スタック（Next.js, Prisma, PostgreSQL）

### 📊 Mermaid 図による視覚化
- アーキテクチャ図、ER図、シーケンス図など
- テキストベースで Git フレンドリー
- プレビューツール不要（GitHub/VSCode で表示可能）

### 💰 現実的なコスト見積もり
- 月額 $25 程度のインフラ構成例
- 無料枠を活用した開発環境
- スモールスタートを前提とした設計

### 🤖 Claude Code 最適化
- カスタムコマンドで効率的な編集
- メタデータ（更新日、バージョン、変更履歴）の自動更新
- ドキュメント品質チェック機能

## Claude Code設定

Claude Code設定をセットアップすると、以下が可能になります：

### 専用スクリプトでセットアップ

```bash
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/setup-claude-config.sh | bash
```

### セットアップ内容

#### `.claude/settings.json`
- ドキュメントファイルの読み書き許可
- Git操作の適切な制御
- 機密ファイルへのアクセス拒否

#### `.claude/CLAUDE.md`
- ドキュメント編集ルール
- Mermaid図・コードブロックのガイドライン
- バージョン管理規約

#### カスタムコマンド
- `/update-doc <ファイル> <変更内容>`: ドキュメント更新
- `/check-doc <ファイル>`: 品質チェック
- `/new-phase-doc <フェーズ> <種類>`: 新規作成

詳細は [examples/README.md](./examples/README.md) を参照してください。

## ディレクトリ構成

```
.
├── README.md                    # このファイル
├── setup-docs.sh               # インタラクティブセットアップ
├── quick-setup.sh              # クイックセットアップ
├── setup-claude-config.sh      # Claude Code設定セットアップ
├── templates/                  # テンプレートファイル
│   ├── 01_planning/           # 計画フェーズ（3テンプレート）
│   ├── 02_design/             # 設計フェーズ（4テンプレート）
│   ├── 03_development/        # 開発フェーズ（3テンプレート）
│   ├── 04_testing/            # テストフェーズ（3テンプレート）
│   ├── 05_operation/          # 運用フェーズ（3テンプレート）
│   └── 06_common/             # 共通ドキュメント（7テンプレート）
└── examples/                   # Claude Code設定サンプル
    ├── README.md              # 設定ガイド
    └── .claude/               # Claude Code設定ファイル
        ├── settings.json
        ├── CLAUDE.md
        └── commands/          # カスタムコマンド
```

## よくある質問

### Q: どのフェーズから始めればいい？

**A:** プロジェクトの状況によります：

- **新規プロジェクト**: `01_planning` から順番に
- **既存プロジェクトのドキュメント整備**: 必要なフェーズのみ
- **とりあえず試したい**: `quick-setup.sh` ですべてダウンロード

### Q: Claude Code 以外の LLM でも使える？

**A:** はい、どの LLM でも使用できます。Markdown 形式なので、ChatGPT、GitHub Copilot、Cursor など、あらゆる LLM ツールで編集可能です。

### Q: テンプレートをカスタマイズしてもいい？

**A:** もちろんです！これらのテンプレートはあくまでベースです。プロジェクトに合わせて自由に編集してください。

### Q: 商用プロジェクトで使える？

**A:** はい、MIT ライセンスなので商用利用可能です。クレジット表記も不要です。

### Q: 企業の大規模プロジェクトでも使える？

**A:** 可能ですが、このテンプレートは小規模プロジェクト（1-3人）向けに最適化されています。大規模プロジェクトの場合は、追加のセクションやプロセスが必要になる可能性があります。

### Q: 英語版はありますか？

**A:** 現在は日本語版のみです。将来的に英語版の追加を検討しています。

## トラブルシューティング

### セットアップスクリプトが動かない

```bash
# curlが正しくインストールされているか確認
curl --version

# パーミッションエラーの場合
chmod +x setup-docs.sh
./setup-docs.sh
```

### Claude Code のカスタムコマンドが表示されない

```bash
# コマンド一覧を確認
/help

# .claude/commands/ ディレクトリを確認
ls -la .claude/commands/

# 設定ファイルを再度ダウンロード
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/setup-claude-config.sh | bash
```

### テンプレートが見つからない

```bash
# ディレクトリを確認
ls -la docs/

# 再度ダウンロード
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
```

## 貢献

バグ報告、機能要望、プルリクエストを歓迎します！

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

**貢献ガイドライン**:
- すべてのテンプレートは日本語で記述
- 小規模プロジェクト向けを維持
- 実践的で動作するコード例を含める
- Mermaid図を積極的に活用
- `.claude/CLAUDE.md` のルールに従う

## 作者

**pon-tanuki**
- GitHub: [@pon-tanuki](https://github.com/pon-tanuki)
- Repository: https://github.com/pon-tanuki/design-docs-for-claude-code

## 謝辞

- [Claude Code](https://docs.claude.com/en/docs/claude-code) - LLMベースの開発ツール
- [Mermaid](https://mermaid.js.org/) - テキストベースの図表生成
- すべてのコントリビューター

## サポート

問題が発生した場合は、以下の方法でサポートを受けられます:

- [Issue を作成](https://github.com/pon-tanuki/design-docs-for-claude-code/issues)
- [Discussions](https://github.com/pon-tanuki/design-docs-for-claude-code/discussions)

## ライセンス

MIT License - 商用利用可能、クレジット表記不要

詳細は [LICENSE](./LICENSE) ファイルを参照してください。

---

⭐ このプロジェクトが役に立った場合は、スターをつけていただけると嬉しいです！
