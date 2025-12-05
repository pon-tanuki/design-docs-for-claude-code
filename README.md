# アプリケーション開発ドキュメントテンプレート集

LLMによる効率的なドキュメント作成を支援するMarkdownテンプレート集です。

## 特徴

- **Markdown形式**: LLMが作成しやすく、人間が読みやすい
- **バージョン管理対応**: Gitで差分確認が容易
- **Mermaid対応**: 図表の可視化が可能
- **構造化**: フェーズ別に整理されたテンプレート

## ディレクトリ構成

```
templates/
├── 01_planning/          # 企画・要件定義フェーズ
├── 02_design/            # 設計フェーズ
├── 03_development/       # 開発フェーズ
├── 04_testing/           # テストフェーズ
├── 05_operation/         # 運用・保守フェーズ
├── 06_common/            # 共通ドキュメント
└── examples/             # サンプル・記入例
```

## クイックスタート

### 方法1: ワンライナーでセットアップ（推奨）

プロジェクトディレクトリで以下のコマンドを実行：

```bash
# すべてのテンプレートをダウンロード
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash

# カスタマイズ例
DOCS_DIR=documents PHASE=planning curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
```

**環境変数**:
- `DOCS_DIR`: ドキュメントディレクトリ名（デフォルト: `docs`）
- `PHASE`: ダウンロードするフェーズ（デフォルト: `all`）
  - `all`: すべて
  - `planning`, `design`, `development`, `testing`, `operation`, `common`

### 方法2: インタラクティブセットアップ

```bash
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/setup-docs.sh | bash
```

対話形式でディレクトリ名やダウンロードするフェーズを選択できます。

### 方法3: 手動ダウンロード

1. 必要なテンプレートを `templates/` から選択
2. プロジェクトにコピーして使用

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

### 4. Claude Code 設定（オプション）

プロジェクトにClaude Code用の設定ファイルをコピーすると、カスタムコマンドが使えて更に効率的になります：

```bash
# 設定ファイルをコピー
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/settings.json -o .claude/settings.json
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/CLAUDE.md -o .claude/CLAUDE.md

# カスタムコマンドをコピー
mkdir -p .claude/commands
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/commands/update-doc.md -o .claude/commands/update-doc.md
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/commands/check-doc.md -o .claude/commands/check-doc.md
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/commands/new-phase-doc.md -o .claude/commands/new-phase-doc.md
```

カスタムコマンドを使うと以下が可能になります：
- `/new-phase-doc planning project_overview` - 新規ドキュメント作成
- `/update-doc <ファイル> <変更内容>` - ドキュメント更新（メタデータ自動更新）
- `/check-doc <ファイル>` - ドキュメント品質チェック

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

## 貢献

バグ報告、機能要望、プルリクエストを歓迎します！

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## ライセンス

MIT License
