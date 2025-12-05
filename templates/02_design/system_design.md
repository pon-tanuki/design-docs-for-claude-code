# システム設計書

## ドキュメント情報

- **作成日**: YYYY-MM-DD
- **最終更新日**: YYYY-MM-DD
- **バージョン**: 1.0.0
- **作成者**: [あなたの名前]
- **クライアント**: [クライアント名]
- **ステータス**: Draft

## 目次

- [1. 概要](#1-概要)
- [2. システム構成](#2-システム構成)
- [3. 技術スタック](#3-技術スタック)
- [4. アーキテクチャ設計](#4-アーキテクチャ設計)
- [5. インフラ構成](#5-インフラ構成)
- [6. セキュリティ設計](#6-セキュリティ設計)
- [7. 開発環境](#7-開発環境)
- [変更履歴](#変更履歴)
- [関連ドキュメント](#関連ドキュメント)

## 1. 概要

### 1.1 システム名

[システム/サービス名]

### 1.2 目的

[このシステムの目的を簡潔に記述]

### 1.3 システムの全体像

[システムの概要を2-3行で説明]

## 2. システム構成

### 2.1 システム構成図

```mermaid
graph TB
    subgraph "クライアント"
        A[Webブラウザ]
        B[モバイルブラウザ]
    end

    subgraph "フロントエンド"
        C[React/Next.js]
    end

    subgraph "バックエンド"
        D[API Server]
    end

    subgraph "データ層"
        E[(Database)]
        F[(ファイルストレージ)]
    end

    subgraph "外部サービス"
        G[認証サービス]
        H[メール送信]
        I[決済サービス]
    end

    A --> C
    B --> C
    C --> D
    D --> E
    D --> F
    D --> G
    D --> H
    D --> I
```

### 2.2 主要コンポーネント

| コンポーネント | 説明 | 責務 |
|--------------|------|------|
| フロントエンド | ユーザーインターフェース | 画面表示、ユーザー操作の受付 |
| API Server | ビジネスロジック処理 | データ処理、外部連携 |
| データベース | データ永続化 | データの保存・取得 |
| [その他] | [説明] | [責務] |

## 3. 技術スタック

### 3.1 フロントエンド

| 分類 | 技術 | バージョン | 選定理由 |
|------|------|-----------|---------|
| フレームワーク | [React/Vue.js/Next.js] | [X.X.X] | [理由] |
| 状態管理 | [Redux/Zustand/Context] | [X.X.X] | [理由] |
| UIライブラリ | [MUI/Tailwind CSS/Chakra UI] | [X.X.X] | [理由] |
| HTTP Client | [Axios/Fetch] | [X.X.X] | [理由] |
| フォーム管理 | [React Hook Form/Formik] | [X.X.X] | [理由] |

### 3.2 バックエンド

| 分類 | 技術 | バージョン | 選定理由 |
|------|------|-----------|---------|
| 言語 | [Node.js/Python/Go] | [X.X.X] | [理由] |
| フレームワーク | [Express/FastAPI/Gin] | [X.X.X] | [理由] |
| ORM/DB Client | [Prisma/SQLAlchemy/GORM] | [X.X.X] | [理由] |
| 認証 | [JWT/NextAuth/Passport] | [X.X.X] | [理由] |
| バリデーション | [Zod/Joi/Pydantic] | [X.X.X] | [理由] |

### 3.3 データベース

| 分類 | 技術 | バージョン | 選定理由 |
|------|------|-----------|---------|
| データベース | [PostgreSQL/MySQL/MongoDB] | [X.X.X] | [理由] |
| キャッシュ | [Redis] | [X.X.X] | [理由] |

### 3.4 インフラ・デプロイ

| 分類 | 技術/サービス | 用途 |
|------|-------------|------|
| ホスティング | [Vercel/Netlify/AWS] | フロントエンドホスティング |
| サーバー | [AWS EC2/Railway/Render] | バックエンドサーバー |
| データベース | [AWS RDS/Supabase/PlanetScale] | データベースホスティング |
| ストレージ | [AWS S3/Cloudinary] | ファイル保存 |
| CI/CD | [GitHub Actions/Vercel] | 自動デプロイ |
| ドメイン | [お名前.com/Cloudflare] | DNS管理 |

### 3.5 開発ツール

| 分類 | ツール | 用途 |
|------|--------|------|
| バージョン管理 | Git/GitHub | ソースコード管理 |
| パッケージ管理 | npm/yarn/pnpm | 依存関係管理 |
| Linter/Formatter | ESLint/Prettier | コード品質管理 |
| テスト | [Jest/Vitest/Pytest] | テスト実行 |

## 4. アーキテクチャ設計

### 4.1 フロントエンド構成

```
src/
├── components/       # 再利用可能なコンポーネント
│   ├── common/      # 汎用コンポーネント
│   └── features/    # 機能別コンポーネント
├── pages/           # ページコンポーネント
├── hooks/           # カスタムフック
├── lib/             # ユーティリティ・ヘルパー
├── api/             # API通信関数
├── types/           # 型定義
├── styles/          # スタイル
└── config/          # 設定ファイル
```

### 4.2 バックエンド構成

```
src/
├── routes/          # ルーティング定義
├── controllers/     # コントローラー（リクエスト処理）
├── services/        # ビジネスロジック
├── models/          # データモデル
├── middleware/      # ミドルウェア
├── utils/           # ユーティリティ
├── config/          # 設定ファイル
└── types/           # 型定義
```

### 4.3 処理フロー

**基本的なリクエスト処理フロー**:

```mermaid
sequenceDiagram
    participant U as ユーザー
    participant F as フロントエンド
    participant M as Middleware
    participant C as Controller
    participant S as Service
    participant D as Database

    U->>F: 操作
    F->>F: 入力検証
    F->>M: APIリクエスト
    M->>M: 認証チェック
    M->>C: リクエスト転送
    C->>C: リクエスト検証
    C->>S: ビジネスロジック実行
    S->>D: データ操作
    D->>S: 結果
    S->>C: 処理結果
    C->>F: レスポンス
    F->>U: 結果表示
```

### 4.4 データフロー

```mermaid
flowchart LR
    A[ユーザー入力] --> B[フロントエンド]
    B --> C[バリデーション]
    C --> D[API送信]
    D --> E[サーバーバリデーション]
    E --> F[ビジネスロジック]
    F --> G[DB操作]
    G --> H[レスポンス生成]
    H --> I[フロントエンド表示]
```

## 5. インフラ構成

### 5.1 本番環境構成

```mermaid
graph TB
    subgraph "ユーザー"
        A[Browser]
    end

    subgraph "CDN"
        B[Cloudflare/CloudFront]
    end

    subgraph "Frontend Hosting"
        C[Vercel/Netlify]
    end

    subgraph "Backend Hosting"
        D[API Server]
    end

    subgraph "Database"
        E[(PostgreSQL)]
    end

    subgraph "Storage"
        F[S3/Cloudinary]
    end

    A --> B
    B --> C
    C --> D
    D --> E
    D --> F
```

### 5.2 環境別設定

| 項目 | 開発環境 | 本番環境 |
|------|---------|---------|
| フロントエンドURL | http://localhost:3000 | https://example.com |
| API URL | http://localhost:8000 | https://api.example.com |
| データベース | ローカルDB | クラウドDB |
| ストレージ | ローカル/開発用バケット | 本番用バケット |

### 5.3 環境変数

**フロントエンド**:
```bash
NEXT_PUBLIC_API_URL=https://api.example.com
NEXT_PUBLIC_APP_URL=https://example.com
```

**バックエンド**:
```bash
DATABASE_URL=postgresql://user:pass@host:5432/db
JWT_SECRET=your-secret-key
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
SMTP_HOST=smtp.example.com
SMTP_PORT=587
```

### 5.4 デプロイフロー

```mermaid
flowchart LR
    A[コード変更] --> B[Git Push]
    B --> C[GitHub]
    C --> D[CI/CD起動]
    D --> E[テスト実行]
    E --> F{テスト結果}
    F -->|成功| G[ビルド]
    F -->|失敗| H[通知]
    G --> I[デプロイ]
    I --> J[本番環境]
```

**デプロイ手順**:
1. `main`ブランチにマージ
2. 自動でCI/CDが起動
3. テスト実行
4. ビルド
5. 本番環境にデプロイ

## 6. セキュリティ設計

### 6.1 認証・認可

**認証方式**: [JWT/セッション/OAuth]

**認証フロー**:
```mermaid
sequenceDiagram
    participant U as ユーザー
    participant F as フロントエンド
    participant A as Auth API
    participant D as Database

    U->>F: ログイン情報入力
    F->>A: 認証リクエスト
    A->>D: ユーザー情報取得
    D->>A: ユーザー情報
    A->>A: パスワード検証
    A->>A: JWTトークン生成
    A->>F: トークン返却
    F->>F: トークン保存
```

**権限管理**:
| ユーザー種別 | 権限 |
|------------|------|
| ゲスト | 閲覧のみ |
| 一般ユーザー | CRUD操作 |
| 管理者 | すべての操作 |

### 6.2 セキュリティ対策

- [ ] **パスワード**: bcrypt等でハッシュ化
- [ ] **JWT**: 適切な有効期限設定(例: 1時間)
- [ ] **HTTPS**: すべての通信をHTTPS化
- [ ] **CORS**: 適切なオリジン設定
- [ ] **XSS対策**: 入力のサニタイズ、エスケープ処理
- [ ] **CSRF対策**: CSRFトークンまたはSameSite Cookie
- [ ] **SQLインジェクション対策**: プリペアドステートメント使用
- [ ] **レート制限**: API呼び出し回数制限
- [ ] **入力バリデーション**: クライアント・サーバー両方で実施
- [ ] **機密情報**: 環境変数で管理、リポジトリにコミットしない

### 6.3 データ保護

- パスワード: bcryptでハッシュ化
- 個人情報: 暗号化して保存
- トークン: HttpOnly Cookieに保存
- API Key: 環境変数で管理

## 7. 開発環境

### 7.1 必要な環境

- Node.js: v[X.X.X]以上
- [言語]: v[X.X.X]以上
- Docker: v[X.X.X]以上 (オプション)
- Git: v[X.X.X]以上

### 7.2 セットアップ手順

**1. リポジトリのクローン**:
```bash
git clone https://github.com/your-repo/project.git
cd project
```

**2. 依存関係のインストール**:
```bash
# フロントエンド
cd frontend
npm install

# バックエンド
cd ../backend
npm install
```

**3. 環境変数の設定**:
```bash
# フロントエンド
cp .env.example .env.local

# バックエンド
cp .env.example .env
```

**4. データベースのセットアップ**:
```bash
# マイグレーション実行
npm run db:migrate

# シードデータ投入（オプション）
npm run db:seed
```

**5. 開発サーバーの起動**:
```bash
# フロントエンド
npm run dev  # http://localhost:3000

# バックエンド
npm run dev  # http://localhost:8000
```

### 7.3 開発時のコマンド

| コマンド | 説明 |
|---------|------|
| `npm run dev` | 開発サーバー起動 |
| `npm run build` | ビルド |
| `npm run lint` | Lint実行 |
| `npm run test` | テスト実行 |
| `npm run db:migrate` | DBマイグレーション |

### 7.4 コーディング規約

**命名規則**:
- コンポーネント: PascalCase (例: `UserProfile.tsx`)
- 関数: camelCase (例: `getUserData`)
- 定数: UPPER_SNAKE_CASE (例: `API_BASE_URL`)
- CSS: kebab-case (例: `user-profile`)

**コミットメッセージ**:
```
<type>: <subject>

例:
feat: ユーザー登録機能を追加
fix: ログインエラーを修正
docs: READMEを更新
```

Type:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `style`: フォーマット
- `refactor`: リファクタリング
- `test`: テスト
- `chore`: その他

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0     | YYYY-MM-DD | [あなたの名前] | 初版作成 |

## 関連ドキュメント

- [要件定義書](../01_planning/requirements_specification.md)
- [データベース設計書](./database_design.md)
- [API仕様書](./api_specification.md)
- [画面設計書](./screen_design.md)
