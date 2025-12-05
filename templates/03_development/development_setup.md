# 開発環境構築手順書

## ドキュメント情報

- **作成日**: YYYY-MM-DD
- **最終更新日**: YYYY-MM-DD
- **バージョン**: 1.0.0
- **作成者**: [あなたの名前]
- **プロジェクト**: [プロジェクト名]
- **ステータス**: Draft

## 目次

- [1. 概要](#1-概要)
- [2. 必要な環境](#2-必要な環境)
- [3. 事前準備](#3-事前準備)
- [4. セットアップ手順](#4-セットアップ手順)
- [5. 動作確認](#5-動作確認)
- [6. よくある問題と解決方法](#6-よくある問題と解決方法)
- [7. 開発ツール設定](#7-開発ツール設定)
- [変更履歴](#変更履歴)
- [関連ドキュメント](#関連ドキュメント)

## 1. 概要

### 1.1 目的

このドキュメントは、プロジェクトの開発環境を構築するための手順を説明します。

### 1.2 所要時間

- 初回セットアップ: 約30-60分
- 2回目以降: 約10-15分

### 1.3 対象OS

- Windows (WSL2推奨)
- Linux (Ubuntu/Debian)
- macOS (最新バージョン)

## 2. 必要な環境

### 2.1 必須ソフトウェア

| ソフトウェア | バージョン | 用途 |
|------------|-----------|------|
| Node.js | v20.x以上 | JavaScript実行環境 |
| npm / yarn / pnpm | 最新版 | パッケージ管理 |
| Git | v2.30以上 | バージョン管理 |
| [言語] | vX.X.X以上 | バックエンド実行環境 |
| Docker | v20.x以上 (任意) | コンテナ実行環境 |

### 2.2 推奨ソフトウェア

| ソフトウェア | 用途 |
|------------|------|
| VS Code | エディタ (推奨) |
| Postman / Insomnia | API動作確認 |
| TablePlus / DBeaver | データベースクライアント |

### 2.3 VS Code 推奨拡張機能

- ESLint
- Prettier
- GitLens
- Error Lens
- [言語固有の拡張機能]
  - TypeScript/JavaScript: TypeScript and JavaScript Language Features
  - Python: Python, Pylance
  - Go: Go

## 3. 事前準備

### 3.1 アカウント準備

以下のアカウントを事前に作成してください:

- [ ] GitHub アカウント
- [ ] [使用する外部サービスのアカウント]
  - AWS (本番デプロイ用)
  - Supabase / Firebase (データベース)
  - Cloudinary (画像ストレージ)

### 3.2 アクセス権限

以下のアクセス権限を取得してください:

- [ ] GitHubリポジトリへのアクセス権
- [ ] 開発環境の環境変数 (クライアント/チームリーダーから受領)

### 3.3 Node.js のインストール

**macOS / Linux (推奨: nvm)**:
```bash
# nvm のインストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# ターミナルを再起動後
nvm install 20
nvm use 20
node --version  # v20.x.x と表示されることを確認
```

**Windows (推奨: nvm-windows)**:
1. https://github.com/coreybutler/nvm-windows/releases から最新版をダウンロード
2. `nvm-setup.exe` を実行してインストール
3. PowerShell / コマンドプロンプトで:
```powershell
nvm install 20
nvm use 20
node --version
```

### 3.4 Git のインストールと設定

**Git のインストール**:
- macOS: `brew install git`
- Windows: https://git-scm.com/download/win
- Linux: `sudo apt-get install git`

**Git の初期設定**:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# SSH Key の生成と登録
ssh-keygen -t ed25519 -C "your.email@example.com"
# Enter を3回押す (パスフレーズなし)

# 公開鍵をコピー
cat ~/.ssh/id_ed25519.pub
# 表示された内容を GitHub の Settings > SSH Keys に登録
```

### 3.5 データベースのセットアップ

**ローカル開発用**:

**オプション1: Docker を使用 (推奨)**:
```bash
# PostgreSQL の起動
docker run --name project-db \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=project_dev \
  -p 5432:5432 \
  -d postgres:15

# 動作確認
docker ps
```

**オプション2: ローカルインストール**:
- macOS: `brew install postgresql@15`
- Windows: https://www.postgresql.org/download/windows/
- Linux: `sudo apt-get install postgresql-15`

## 4. セットアップ手順

### 4.1 リポジトリのクローン

```bash
# SSH を使用 (推奨)
git clone git@github.com:username/project-name.git
cd project-name

# または HTTPS を使用
git clone https://github.com/username/project-name.git
cd project-name
```

### 4.2 プロジェクト構成の確認

```bash
# ディレクトリ構成
.
├── frontend/          # フロントエンドコード
├── backend/           # バックエンドコード
├── docs/             # ドキュメント
├── .env.example      # 環境変数のサンプル
└── README.md
```

### 4.3 フロントエンドのセットアップ

```bash
cd frontend

# 依存関係のインストール
npm install
# または
yarn install
# または
pnpm install

# 環境変数の設定
cp .env.example .env.local

# .env.local を編集
# エディタで開いて必要な値を設定
```

**`.env.local` の設定例**:
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 4.4 バックエンドのセットアップ

```bash
cd backend

# 依存関係のインストール
npm install
# または (Pythonの場合)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# 環境変数の設定
cp .env.example .env

# .env を編集
```

**`.env` の設定例**:
```bash
# データベース
DATABASE_URL=postgresql://postgres:password@localhost:5432/project_dev

# JWT
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=1h

# 外部サービス
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=ap-northeast-1

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=
```

### 4.5 データベースマイグレーション

```bash
cd backend

# マイグレーションの実行
npm run db:migrate
# または
python manage.py migrate

# シードデータの投入 (開発用テストデータ)
npm run db:seed
# または
python manage.py seed
```

**マイグレーション確認**:
```bash
# データベースに接続
psql postgresql://postgres:password@localhost:5432/project_dev

# テーブル一覧を確認
\dt

# テーブルの内容を確認
SELECT * FROM users;

# 終了
\q
```

### 4.6 初回ビルドと起動

**フロントエンド**:
```bash
cd frontend

# 開発サーバー起動
npm run dev

# ブラウザで http://localhost:3000 にアクセス
```

**バックエンド**:
```bash
cd backend

# 開発サーバー起動
npm run dev
# または
python manage.py runserver

# 別のターミナルで動作確認
curl http://localhost:8000/api/health
```

## 5. 動作確認

### 5.1 フロントエンド動作確認

```bash
# ブラウザで以下にアクセス
open http://localhost:3000

# 確認項目:
# - [ ] ページが正常に表示される
# - [ ] コンソールにエラーがない
# - [ ] ホットリロードが動作する (ファイル保存時に自動更新)
```

### 5.2 バックエンド動作確認

```bash
# ヘルスチェック
curl http://localhost:8000/api/health

# レスポンス例:
# {"status":"ok","timestamp":"2024-01-01T00:00:00Z"}

# ユーザー一覧取得 (認証なし)
curl http://localhost:8000/api/users

# 認証API確認
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

### 5.3 データベース接続確認

```bash
# データベースクライアントで接続
# Host: localhost
# Port: 5432
# Database: project_dev
# User: postgres
# Password: password

# または psql で確認
psql postgresql://postgres:password@localhost:5432/project_dev
\dt  # テーブル一覧
\q   # 終了
```

### 5.4 統合確認

```bash
# フロントエンドとバックエンドの両方を起動した状態で:
# 1. http://localhost:3000 にアクセス
# 2. ユーザー登録画面で新規ユーザーを作成
# 3. ログインできることを確認
# 4. ダッシュボードが表示されることを確認
```

## 6. よくある問題と解決方法

### 6.1 ポートが既に使用されている

**症状**:
```
Error: listen EADDRINUSE: address already in use :::3000
```

**解決方法**:
```bash
# ポートを使用しているプロセスを確認
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# プロセスを終了
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# または別のポートを使用
PORT=3001 npm run dev
```

### 6.2 モジュールが見つからない

**症状**:
```
Error: Cannot find module 'xxx'
```

**解決方法**:
```bash
# node_modules を削除して再インストール
rm -rf node_modules
rm package-lock.json  # または yarn.lock, pnpm-lock.yaml
npm install
```

### 6.3 データベース接続エラー

**症状**:
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**解決方法**:
```bash
# データベースが起動しているか確認
docker ps  # Docker使用時
pg_isready  # PostgreSQL直接インストール時

# 起動していない場合
docker start project-db  # Docker
brew services start postgresql@15  # macOS Homebrew

# 接続情報が正しいか確認
echo $DATABASE_URL
```

### 6.4 環境変数が読み込まれない

**症状**:
API URLが undefined になる

**解決方法**:
```bash
# .env ファイルが存在するか確認
ls -la .env*

# .env.local (フロントエンド) があるか確認
# Next.js の場合、変数名は NEXT_PUBLIC_ で始まる必要がある

# サーバーを再起動
# 環境変数の変更後は必ず再起動が必要
```

### 6.5 マイグレーションエラー

**症状**:
```
Error: relation "users" already exists
```

**解決方法**:
```bash
# データベースをリセット
npm run db:reset
# または
dropdb project_dev
createdb project_dev
npm run db:migrate
```

## 7. 開発ツール設定

### 7.1 VS Code 設定

**`.vscode/settings.json`**:
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.updateImportsOnFileMove.enabled": "always",
  "files.exclude": {
    "**/.git": true,
    "**/node_modules": true,
    "**/.next": true,
    "**/__pycache__": true
  }
}
```

**`.vscode/extensions.json`**:
```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "eamodio.gitlens",
    "usernamehw.errorlens"
  ]
}
```

### 7.2 Git Hooks (Husky)

プロジェクトには pre-commit hook が設定されています。

```bash
# 自動的にセットアップされるが、されない場合:
npx husky install

# コミット時に自動で Lint と Format が実行される
git commit -m "feat: 新機能追加"
# → ESLint、Prettier が自動実行される
```

### 7.3 デバッグ設定

**VS Code デバッグ設定 (`.vscode/launch.json`)**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js: debug full stack",
      "type": "node-terminal",
      "request": "launch",
      "command": "npm run dev",
      "serverReadyAction": {
        "pattern": "started server on .+, url: (https?://.+)",
        "uriFormat": "%s",
        "action": "debugWithChrome"
      }
    }
  ]
}
```

### 7.4 便利なコマンド

**package.json に追加推奨**:
```json
{
  "scripts": {
    "dev": "開発サーバー起動",
    "build": "本番ビルド",
    "lint": "Lint実行",
    "lint:fix": "Lint自動修正",
    "format": "Prettier実行",
    "test": "テスト実行",
    "test:watch": "テスト監視モード",
    "db:migrate": "マイグレーション実行",
    "db:seed": "シードデータ投入",
    "db:reset": "データベースリセット"
  }
}
```

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0     | YYYY-MM-DD | [あなたの名前] | 初版作成 |

## 関連ドキュメント

- [コーディング規約](./coding_standards.md)
- [システム設計書](../02_design/system_design.md)
- [API仕様書](../02_design/api_specification.md)
