# Claude Code 設定ファイル サンプル

このディレクトリには、テンプレートを導入したプロジェクトで使用するClaude Code設定ファイルのサンプルが含まれています。

## 📁 含まれるファイル

```
examples/.claude/
├── settings.json           # Claude Code設定ファイル
├── CLAUDE.md              # プロジェクト固有ルール定義
└── commands/
    ├── update-doc.md      # ドキュメント更新コマンド
    ├── check-doc.md       # ドキュメント品質チェックコマンド
    └── new-phase-doc.md   # 新規ドキュメント作成コマンド
```

## 🚀 セットアップ方法

### 1. テンプレートをダウンロード

まず、設計書テンプレートをプロジェクトにダウンロードします：

```bash
cd your-project
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/quick-setup.sh | bash
```

### 2. Claude Code設定をコピー

次に、Claude Code設定ファイルをプロジェクトルートにコピーします：

```bash
# すべての設定ファイルをコピー
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/settings.json -o .claude/settings.json
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/CLAUDE.md -o .claude/CLAUDE.md

# カスタムコマンドをコピー
mkdir -p .claude/commands
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/commands/update-doc.md -o .claude/commands/update-doc.md
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/commands/check-doc.md -o .claude/commands/check-doc.md
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/examples/.claude/commands/new-phase-doc.md -o .claude/commands/new-phase-doc.md
```

### 3. 設定のカスタマイズ

`.claude/settings.json` を編集して、プロジェクトに合わせて調整します：

```json
{
  "env": {
    "DOCS_DIR": "docs",  // ドキュメントディレクトリ名を変更
    "PROJECT_PHASE": "planning"  // 現在のフェーズ
  }
}
```

## 📖 使い方

### Claude Code の起動

```bash
claude
```

### カスタムコマンドの使用

#### 1. 新規ドキュメント作成

```bash
/new-phase-doc planning project_overview
```

これにより、プロジェクト概要書のテンプレートが `docs/01_planning/project_overview.md` に作成されます。

#### 2. ドキュメント編集

通常のプロンプトでドキュメントを編集：

```
docs/01_planning/project_overview.md を編集してください。
プロジェクト名は「ECサイト構築」、予算は100万円、納期は3ヶ月です。
```

または、`/update-doc` コマンドを使用：

```bash
/update-doc docs/01_planning/project_overview.md 予算を150万円に変更
```

#### 3. ドキュメント品質チェック

```bash
/check-doc docs/01_planning/project_overview.md
```

品質チェック結果と改善提案が表示されます。

## 🎯 実践例

### シナリオ: 新規プロジェクトのドキュメント作成

```bash
# 1. プロジェクト概要書を作成
/new-phase-doc planning project_overview

# 2. Claude Code で内容を充実させる
プロンプト: "docs/01_planning/project_overview.md を、
以下の情報で充実させてください：
- プロジェクト名: タスク管理アプリ
- 予算: 80万円
- 納期: 2ヶ月
- 主な機能: タスク登録、期限管理、通知機能"

# 3. 品質チェック
/check-doc docs/01_planning/project_overview.md

# 4. 要件定義書を作成
/new-phase-doc planning requirements_specification

# 5. 要件を追加
プロンプト: "docs/01_planning/requirements_specification.md に、
以下の機能要件を追加してください：
1. ユーザー認証機能
2. タスクのCRUD操作
3. 期限通知機能"
```

### シナリオ: 既存ドキュメントの更新

```bash
# 1. 変更内容を反映
/update-doc docs/02_design/system_design.md データベースをPostgreSQLに変更

# 2. 品質チェック
/check-doc docs/02_design/system_design.md

# 3. 関連ドキュメントも更新
プロンプト: "データベースをPostgreSQLに変更したので、
関連するドキュメントも更新してください"
```

## ⚙️ 設定ファイルの詳細

### settings.json

#### permissions.allow

Claude Codeが自動的に実行できる操作：

- Markdownファイルの読み書き
- ディレクトリ作成
- Git status/diff/log/add

#### permissions.ask

実行前に確認を求める操作：

- Git commit
- Git push
- ソースコードの変更

#### permissions.deny

実行を拒否する操作：

- 機密ファイル（.env等）の読み書き
- 破壊的なコマンド（rm -rf等）
- 強制プッシュ

### CLAUDE.md

プロジェクト固有のルールを定義：

- ドキュメント編集時のルール
- バージョン管理方針
- Git コミットルール
- 禁止事項

## 🔧 カスタマイズ例

### ドキュメントディレクトリ名の変更

`docs/` ではなく `documentation/` を使いたい場合：

```json
// .claude/settings.json
{
  "permissions": {
    "allow": [
      "Read(documentation/**/*.md)",  // docsをdocumentationに変更
      "Write(documentation/**/*.md)",
      ...
    ]
  },
  "env": {
    "DOCS_DIR": "documentation"  // 環境変数も変更
  }
}
```

### プロジェクト固有ルールの追加

`.claude/CLAUDE.md` に追記：

```markdown
## プロジェクト固有ルール

### 技術スタック
- フロントエンド: Next.js 14
- バックエンド: NestJS
- データベース: PostgreSQL
- インフラ: AWS

### ドキュメントに含める情報
- すべてのAPIエンドポイントにはcURLサンプルを含める
- 環境変数は必ずサンプルファイルを用意
- デプロイ手順は初心者でも理解できるよう詳細に記述
```

### 追加カスタムコマンドの作成

`.claude/commands/sync-docs.md`:

```markdown
---
description: 複数ドキュメント間の整合性を確認
allowed-tools: ["Read"]
---

以下のドキュメント間で整合性をチェックしてください：
- docs/01_planning/requirements_specification.md
- docs/02_design/system_design.md
- docs/02_design/api_specification.md

不整合があれば報告してください。
```

## 📝 Tips

### Git管理

`.claude/settings.json` と `.claude/CLAUDE.md` は Git にコミットし、チーム全体で共有することを推奨します。

`.claude/settings.local.json` は個人の設定なので `.gitignore` に追加：

```gitignore
.claude/settings.local.json
```

### 効率的な使い方

1. **新規プロジェクト開始時**: `/new-phase-doc` で一気にドキュメントを作成
2. **定期的なチェック**: `/check-doc` で品質を維持
3. **変更時**: `/update-doc` で確実にメタデータを更新

### トラブルシューティング

#### コマンドが見つからない

```bash
# コマンド一覧を確認
/help

# カスタムコマンドが表示されない場合は、ファイルの配置を確認
ls -la .claude/commands/
```

#### 権限エラー

```
Error: Permission denied
```

`.claude/settings.json` の `permissions.allow` に該当する操作が含まれているか確認してください。

## 🔗 関連リンク

- [メインリポジトリ](https://github.com/pon-tanuki/design-docs-for-claude-code)
- [テンプレート一覧](../templates/)
- [Claude Code 公式ドキュメント](https://docs.claude.com/en/docs/claude-code)

## 📄 ライセンス

MIT License - 商用利用可能
