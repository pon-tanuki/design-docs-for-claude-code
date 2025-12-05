---
description: テンプレートから新しいフェーズのドキュメントを作成
argument-hint: <フェーズ> <ドキュメント種類>
allowed-tools: ["Read", "Write", "Bash"]
---

**$1** フェーズの **$2** ドキュメントを新規作成します。

## 実行手順

### 1. フェーズとドキュメント種類の確認

**利用可能なフェーズ**:
- `planning` (01_planning): 計画フェーズ
- `design` (02_design): 設計フェーズ
- `development` (03_development): 開発フェーズ
- `testing` (04_testing): テストフェーズ
- `operation` (05_operation): 運用フェーズ
- `common` (06_common): 共通ドキュメント

**各フェーズのドキュメント種類**:

#### planning
- `project_overview`: プロジェクト概要書
- `requirements_specification`: 要件定義書
- `use_case_document`: ユースケース記述書

#### design
- `system_design`: システム設計書
- `database_design`: データベース設計書
- `api_specification`: API仕様書
- `screen_design`: 画面設計書

#### development
- `coding_standards`: コーディング規約
- `development_setup`: 開発環境構築手順
- `technical_specification`: 技術仕様書

#### testing
- `test_plan`: テスト計画書
- `test_case_specification`: テストケース仕様書
- `test_report`: テスト報告書

#### operation
- `operation_manual`: 運用手順書
- `incident_response`: 障害対応手順書
- `maintenance_plan`: 保守・メンテナンス計画書

#### common
- `README_template`: README
- `CHANGELOG_template`: CHANGELOG
- `ADR_template`: アーキテクチャ決定記録
- `security_design`: セキュリティ設計書
- `performance_design`: パフォーマンス設計書

### 2. テンプレートの取得

GitHubから該当するテンプレートを取得します：

```bash
curl -fsSL https://raw.githubusercontent.com/pon-tanuki/design-docs-for-claude-code/main/templates/$PHASE/$DOCUMENT.md
```

**フェーズ番号のマッピング**:
- planning → 01_planning
- design → 02_design
- development → 03_development
- testing → 04_testing
- operation → 05_operation
- common → 06_common

### 3. ドキュメントのカスタマイズ

テンプレートを読み込み、以下をカスタマイズします：

#### ドキュメント情報セクション
```markdown
- **作成日**: YYYY-MM-DD  # 今日の日付
- **最終更新日**: YYYY-MM-DD  # 今日の日付
- **バージョン**: 1.0.0  # 初版
- **作成者**: [プロジェクトの作成者名]
- **プロジェクト**: [プロジェクト名]  # 環境変数または質問
- **ステータス**: Draft  # 初期はDraft
```

#### プレースホルダーの置換
- `[プロジェクト名]` → 実際のプロジェクト名
- `[あなたの名前]` → 作成者名
- `YYYY-MM-DD` → 今日の日付
- その他のプレースホルダー

### 4. ファイルの保存

以下のパスに保存：
```
docs/$PHASE_NUMBER/$DOCUMENT.md
```

例:
- `docs/01_planning/project_overview.md`
- `docs/02_design/system_design.md`

### 5. 確認メッセージ

作成完了後、以下を表示：

```
✅ ドキュメント作成完了！

📄 ファイル: docs/$PHASE_NUMBER/$DOCUMENT.md
📋 種類: [ドキュメント名]
📅 作成日: YYYY-MM-DD

次のステップ:
1. プロジェクトの要件に応じて内容を編集
2. `/update-doc` コマンドで更新
3. `/check-doc` コマンドで品質確認
```

## 使用例

### 例1: プロジェクト概要書の作成
```
/new-phase-doc planning project_overview
```

### 例2: システム設計書の作成
```
/new-phase-doc design system_design
```

### 例3: テスト計画書の作成
```
/new-phase-doc testing test_plan
```

## エラーハンドリング

### 不正なフェーズ名
```
❌ エラー: '$1' は無効なフェーズ名です

利用可能なフェーズ:
- planning
- design
- development
- testing
- operation
- common
```

### 不正なドキュメント種類
```
❌ エラー: '$2' は '$1' フェーズで利用できないドキュメント種類です

'$1' で利用可能なドキュメント:
- [利用可能なドキュメントのリスト]
```

### ファイルが既に存在する場合
```
⚠️ 警告: docs/$PHASE/$DOCUMENT.md は既に存在します

上書きしますか？ [y/N]
```

## 注意事項

- ディレクトリが存在しない場合は自動的に作成されます
- 既存のファイルを上書きする前に確認を求めます
- テンプレートの取得に失敗した場合は、ローカルのテンプレートを使用します
