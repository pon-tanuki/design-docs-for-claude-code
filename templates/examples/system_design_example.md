# システム設計書 - タスク管理アプリ「TaskFlow」

## ドキュメント情報

- **作成日**: 2024-01-15
- **最終更新日**: 2024-01-20
- **バージョン**: 1.2.0
- **作成者**: 田中太郎（フリーランス開発者）
- **プロジェクト**: TaskFlow - シンプルなタスク管理アプリ
- **ステータス**: Approved
- **関連ドキュメント**: [プロジェクト概要書](./project_overview_example.md), [データベース設計書](./database_design_example.md), [API仕様書](./api_specification_example.md)

## 目次

- [1. システム概要](#1-システム概要)
- [2. アーキテクチャ設計](#2-アーキテクチャ設計)
- [3. 技術スタック](#3-技術スタック)
- [4. インフラ構成](#4-インフラ構成)
- [5. セキュリティ設計](#5-セキュリティ設計)
- [6. パフォーマンス設計](#6-パフォーマンス設計)
- [7. データフロー](#7-データフロー)
- [8. 外部サービス連携](#8-外部サービス連携)
- [9. 開発・デプロイフロー](#9-開発デプロイフロー)
- [変更履歴](#変更履歴)

## 1. システム概要

### 1.1 システムの目的

個人・小規模チーム向けのシンプルで使いやすいタスク管理Webアプリケーション。リアルタイム同期、期限管理、通知機能を提供し、チームの生産性向上を支援する。

### 1.2 システムの特徴

- 📱 レスポンシブデザイン（PC・スマホ対応）
- ⚡ 高速な初期表示（3秒以内）
- 🔔 メール通知機能
- 🔒 セキュアな認証・認可
- 📊 直感的なタスク管理UI
- 🌐 RESTful API設計

### 1.3 想定ユーザー数・負荷

- **初期ユーザー数**: 10人（株式会社ABC社内）
- **1年後目標**: 50人
- **同時接続数**: 最大10人
- **月間タスク作成数**: 約500件
- **データ保持期間**: 無制限（削除まで）

## 2. アーキテクチャ設計

### 2.1 全体アーキテクチャ

```mermaid
graph TB
    subgraph "クライアント"
        Browser[Webブラウザ]
        Mobile[モバイルブラウザ]
    end

    subgraph "CDN/Edge"
        Vercel[Vercel Edge Network]
    end

    subgraph "アプリケーション層"
        NextJS[Next.js 14<br/>App Router]
        API[API Routes<br/>REST API]
        Auth[NextAuth.js<br/>認証]
    end

    subgraph "データ層"
        Prisma[Prisma ORM]
        PostgreSQL[(PostgreSQL 15<br/>Supabase)]
    end

    subgraph "外部サービス"
        Email[Resend<br/>メール送信]
        Analytics[Vercel Analytics<br/>監視・分析]
    end

    Browser --> Vercel
    Mobile --> Vercel
    Vercel --> NextJS
    NextJS --> API
    API --> Auth
    API --> Prisma
    Prisma --> PostgreSQL
    API --> Email
    NextJS --> Analytics
```

### 2.2 アーキテクチャパターン

**採用パターン**: モノリシックアーキテクチャ（Next.js フルスタック）

**理由**:
- 小規模プロジェクト（10人）で複雑性を抑える
- フロント・バックエンドの一元管理で開発効率向上
- Vercelへのデプロイが簡単
- コスト削減（単一サービスで完結）

### 2.3 ディレクトリ構造

```
taskflow/
├── app/                      # Next.js App Router
│   ├── (auth)/              # 認証関連ページ
│   │   ├── login/
│   │   └── register/
│   ├── (dashboard)/         # ダッシュボード（認証後）
│   │   ├── tasks/
│   │   ├── profile/
│   │   └── settings/
│   ├── api/                 # API Routes
│   │   ├── auth/[...nextauth]/route.ts
│   │   ├── tasks/route.ts
│   │   ├── tasks/[id]/route.ts
│   │   └── notifications/route.ts
│   ├── layout.tsx           # ルートレイアウト
│   └── page.tsx             # トップページ
├── components/              # Reactコンポーネント
│   ├── ui/                  # 汎用UIコンポーネント
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Modal.tsx
│   │   └── Badge.tsx
│   ├── tasks/               # タスク関連コンポーネント
│   │   ├── TaskList.tsx
│   │   ├── TaskCard.tsx
│   │   └── TaskForm.tsx
│   └── layout/              # レイアウトコンポーネント
│       ├── Header.tsx
│       ├── Sidebar.tsx
│       └── Footer.tsx
├── lib/                     # ユーティリティ・設定
│   ├── prisma.ts            # Prismaクライアント
│   ├── auth.ts              # NextAuth設定
│   ├── email.ts             # メール送信
│   └── utils.ts             # 共通関数
├── prisma/                  # Prismaスキーマ
│   ├── schema.prisma
│   └── migrations/
├── public/                  # 静的ファイル
├── types/                   # TypeScript型定義
│   └── index.ts
├── .env.local               # 環境変数
├── next.config.js
├── package.json
├── tsconfig.json
└── tailwind.config.ts
```

## 3. 技術スタック

### 3.1 フロントエンド

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| **Next.js** | 14.x | フレームワーク | App Router、RSC、最新機能、Vercelとの親和性 |
| **React** | 18.x | UIライブラリ | デファクトスタンダード、豊富なエコシステム |
| **TypeScript** | 5.x | 言語 | 型安全性、開発効率向上、バグ削減 |
| **Tailwind CSS** | 3.x | スタイリング | ユーティリティファースト、高速開発 |
| **Zustand** | 4.x | 状態管理 | 軽量、シンプル、学習コスト低 |
| **React Hook Form** | 7.x | フォーム管理 | パフォーマンス、バリデーション |
| **Zod** | 3.x | スキーマバリデーション | 型安全、フロント・バック共通 |
| **date-fns** | 2.x | 日付操作 | 軽量、Tree-shakable |

### 3.2 バックエンド

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| **Node.js** | 20.x LTS | ランタイム | 最新LTS、安定性、Vercel対応 |
| **Next.js API Routes** | 14.x | API | フロントと一体化、型共有、開発効率 |
| **NextAuth.js** | 4.x | 認証 | Next.js統合、多様なプロバイダ対応 |
| **Prisma** | 5.x | ORM | 型安全、マイグレーション、開発体験 |
| **Zod** | 3.x | バリデーション | フロントと共通、型推論 |
| **Resend** | 1.x | メール送信 | シンプル、開発者フレンドリー |

### 3.3 データベース

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| **PostgreSQL** | 15.x | RDBMS | 信頼性、機能豊富、Supabase無料枠 |
| **Supabase** | - | ホスティング | 無料枠500MB、自動バックアップ |

### 3.4 インフラ・DevOps

| 技術 | 用途 | 選定理由 |
|------|------|----------|
| **Vercel** | ホスティング | Next.js最適化、無料枠、自動デプロイ |
| **GitHub** | ソースコード管理 | 標準、CI/CD連携 |
| **GitHub Actions** | CI/CD | 無料枠、Vercel連携 |
| **Vercel Analytics** | 監視・分析 | 無料、統合、Core Web Vitals |

## 4. インフラ構成

### 4.1 本番環境構成図

```mermaid
graph LR
    subgraph "ユーザー"
        User[エンドユーザー]
    end

    subgraph "Vercel"
        Edge[Edge Network<br/>CDN]
        App[Next.js App<br/>Serverless Functions]
    end

    subgraph "Supabase"
        DB[(PostgreSQL<br/>Primary)]
        Backup[(自動バックアップ<br/>毎日)]
    end

    subgraph "Resend"
        Mail[メール送信API]
    end

    User -->|HTTPS| Edge
    Edge -->|SSR/API| App
    App -->|SQL| DB
    DB -.->|自動| Backup
    App -->|SMTP| Mail
    Mail -->|Email| User
```

### 4.2 環境別構成

#### 開発環境（Local）

```
開発者PC
├── Next.js Dev Server (localhost:3000)
├── PostgreSQL (Docker)
└── Resend Test Mode
```

**セットアップ**:
```bash
# Docker で PostgreSQL 起動
docker run --name taskflow-db -e POSTGRES_PASSWORD=dev -p 5432:5432 -d postgres:15

# 環境変数設定
cp .env.example .env.local

# 依存関係インストール
npm install

# DBマイグレーション
npx prisma migrate dev

# 開発サーバー起動
npm run dev
```

#### ステージング環境（Vercel Preview）

- **URL**: `taskflow-{branch}-{hash}.vercel.app`
- **DB**: Supabase開発用DB
- **用途**: PR確認、検証
- **デプロイ**: Gitプッシュで自動

#### 本番環境（Vercel Production）

- **URL**: `taskflow.example.com`
- **DB**: Supabase本番DB
- **デプロイ**: mainブランチマージで自動
- **ロールバック**: Vercel管理画面から即座に可能

### 4.3 スケーリング戦略

**現状（Phase 1）**: 10ユーザー
- Vercel無料枠（Hobby）
- Supabase無料枠（500MB）
- **月額コスト**: $0

**50ユーザー到達時（Phase 2）**:
- Vercel Pro（$20/月）
- Supabase Pro（$25/月）
- **月額コスト**: $45

**スケールアウトポイント**:
- 100ユーザー超: Vercelのスケール自動対応
- DB容量1GB超: Supabaseプラン変更
- 同時接続100超: コネクションプーリング検討

## 5. セキュリティ設計

### 5.1 認証・認可

#### 認証フロー

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant Browser as ブラウザ
    participant NextAuth as NextAuth.js
    participant DB as PostgreSQL

    User->>Browser: メール/パスワード入力
    Browser->>NextAuth: POST /api/auth/signin
    NextAuth->>DB: ユーザー検証
    DB-->>NextAuth: ユーザー情報
    NextAuth->>NextAuth: JWT生成
    NextAuth-->>Browser: Set-Cookie (JWT)
    Browser-->>User: ログイン完了
```

#### 実装例

```typescript
// lib/auth.ts
import { NextAuthOptions } from 'next-auth';
import CredentialsProvider from 'next-auth/providers/credentials';
import { PrismaAdapter } from '@next-auth/prisma-adapter';
import { prisma } from './prisma';
import bcrypt from 'bcryptjs';

export const authOptions: NextAuthOptions = {
  adapter: PrismaAdapter(prisma),
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null;
        }

        const user = await prisma.user.findUnique({
          where: { email: credentials.email }
        });

        if (!user || !user.hashedPassword) {
          return null;
        }

        const isPasswordValid = await bcrypt.compare(
          credentials.password,
          user.hashedPassword
        );

        if (!isPasswordValid) {
          return null;
        }

        return {
          id: user.id,
          email: user.email,
          name: user.name,
        };
      }
    })
  ],
  session: {
    strategy: 'jwt',
    maxAge: 30 * 24 * 60 * 60, // 30日
  },
  pages: {
    signIn: '/login',
    error: '/login',
  },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
      }
      return session;
    }
  }
};
```

### 5.2 セキュリティ対策

| 脅威 | 対策 | 実装 |
|------|------|------|
| SQLインジェクション | Prisma ORM使用 | パラメータ化クエリ自動生成 |
| XSS | React自動エスケープ | dangerouslySetInnerHTML禁止 |
| CSRF | NextAuth内蔵保護 | CSRFトークン自動生成 |
| パスワード漏洩 | bcrypt ハッシュ化 | ソルト10ラウンド |
| セッションハイジャック | HttpOnly Cookie | Secure, SameSite=Lax |
| 中間者攻撃 | HTTPS強制 | Vercel自動証明書 |

### 5.3 環境変数管理

```bash
# .env.local（Gitコミット禁止）
DATABASE_URL="postgresql://user:pass@host:5432/taskflow"
NEXTAUTH_SECRET="ランダム文字列（32文字以上）"
NEXTAUTH_URL="https://taskflow.example.com"
RESEND_API_KEY="re_xxxxxxxxxxxx"
```

**管理方法**:
- ローカル: `.env.local`（.gitignore登録済み）
- Vercel: 管理画面で環境変数設定
- シークレット: Vercel Secrets（暗号化保存）

## 6. パフォーマンス設計

### 6.1 目標指標

| 指標 | 目標値 | 計測方法 |
|------|--------|----------|
| **LCP** (Largest Contentful Paint) | < 2.5秒 | Lighthouse |
| **FID** (First Input Delay) | < 100ms | Lighthouse |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Lighthouse |
| **初期表示** | < 3秒 | Vercel Analytics |
| **TTI** (Time to Interactive) | < 3.8秒 | Lighthouse |
| **Lighthouse Performance** | > 90点 | Lighthouse |

### 6.2 最適化戦略

#### 6.2.1 フロントエンド最適化

**React Server Components（RSC）活用**:
```typescript
// app/(dashboard)/tasks/page.tsx
import { prisma } from '@/lib/prisma';
import { TaskList } from '@/components/tasks/TaskList';

// サーバーサイドでデータ取得（RSC）
async function getTasks(userId: string) {
  return await prisma.task.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });
}

export default async function TasksPage() {
  const tasks = await getTasks('user-id'); // サーバーで実行

  return <TaskList tasks={tasks} />; // クライアントに送信
}
```

**画像最適化**:
```typescript
import Image from 'next/image';

<Image
  src="/avatar.png"
  alt="User Avatar"
  width={40}
  height={40}
  placeholder="blur"
  priority // Above the fold
/>
```

**コード分割**:
```typescript
// 動的インポート（遅延ロード）
const TaskModal = dynamic(() => import('@/components/tasks/TaskModal'), {
  ssr: false,
  loading: () => <LoadingSpinner />
});
```

#### 6.2.2 バックエンド最適化

**データベースインデックス**:
```prisma
model Task {
  id        String   @id @default(cuid())
  userId    String
  status    Status
  createdAt DateTime @default(now())

  @@index([userId]) // ユーザーIDでの検索高速化
  @@index([userId, status]) // 複合インデックス
  @@index([createdAt]) // 日付ソート高速化
}
```

**クエリ最適化**:
```typescript
// ❌ N+1問題
const tasks = await prisma.task.findMany();
for (const task of tasks) {
  const user = await prisma.user.findUnique({ where: { id: task.userId } });
}

// ✅ includeで一括取得
const tasks = await prisma.task.findMany({
  include: { user: true }
});
```

### 6.3 キャッシング戦略

```typescript
// app/api/tasks/route.ts
export const dynamic = 'force-dynamic'; // キャッシュ無効
export const revalidate = 60; // 60秒ごとに再検証

// 静的ページはビルド時生成
export const generateStaticParams = async () => {
  const tasks = await prisma.task.findMany();
  return tasks.map((task) => ({ id: task.id }));
};
```

## 7. データフロー

### 7.1 タスク作成フロー

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant UI as TaskForm
    participant API as POST /api/tasks
    participant Validation as Zod検証
    participant Prisma as Prisma ORM
    participant DB as PostgreSQL

    User->>UI: タスク情報入力
    UI->>UI: React Hook Form検証
    UI->>API: POST /api/tasks
    API->>Validation: リクエストボディ検証
    Validation-->>API: 検証OK
    API->>Prisma: task.create()
    Prisma->>DB: INSERT INTO tasks
    DB-->>Prisma: タスクID返却
    Prisma-->>API: 作成完了
    API-->>UI: 201 Created
    UI-->>User: 成功メッセージ表示
```

### 7.2 期限通知フロー

```mermaid
sequenceDiagram
    participant Cron as Vercel Cron Jobs
    participant API as GET /api/notifications
    participant DB as PostgreSQL
    participant Resend as Resend API
    participant User as ユーザー

    Cron->>API: 毎日9:00AM実行
    API->>DB: 期限1日前のタスク検索
    DB-->>API: タスクリスト返却
    loop 各タスク
        API->>Resend: メール送信リクエスト
        Resend->>User: 通知メール送信
    end
    API-->>Cron: 完了
```

## 8. 外部サービス連携

### 8.1 Resend（メール送信）

**用途**: 期限通知メール

**実装例**:
```typescript
// lib/email.ts
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendTaskDueNotification(
  to: string,
  taskTitle: string,
  dueDate: Date
) {
  await resend.emails.send({
    from: 'TaskFlow <noreply@taskflow.example.com>',
    to,
    subject: `[TaskFlow] タスク期限通知: ${taskTitle}`,
    html: `
      <h2>タスクの期限が近づいています</h2>
      <p><strong>${taskTitle}</strong></p>
      <p>期限: ${dueDate.toLocaleDateString('ja-JP')}</p>
      <a href="https://taskflow.example.com/tasks">タスクを確認</a>
    `
  });
}
```

**料金**:
- 無料枠: 月3,000通
- 超過: $0.001/通

### 8.2 Vercel Analytics

**用途**: パフォーマンス監視、エラートラッキング

**設定**:
```typescript
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  );
}
```

## 9. 開発・デプロイフロー

### 9.1 Git ブランチ戦略

```mermaid
gitGraph
    commit id: "Initial"
    branch develop
    checkout develop
    commit id: "Setup"
    branch feature/task-crud
    checkout feature/task-crud
    commit id: "Add task creation"
    commit id: "Add task editing"
    checkout develop
    merge feature/task-crud
    checkout main
    merge develop tag: "v1.0.0"
```

**ブランチルール**:
- `main`: 本番環境（保護）
- `develop`: 開発統合ブランチ
- `feature/*`: 機能開発ブランチ
- `fix/*`: バグ修正ブランチ

### 9.2 CI/CDパイプライン

```mermaid
graph LR
    A[Git Push] --> B[GitHub Actions]
    B --> C{テスト}
    C -->|Pass| D[Vercel Preview]
    C -->|Fail| E[通知]
    D --> F{PRレビュー}
    F -->|Approve| G[Merge to main]
    G --> H[Vercel Production]
    H --> I[デプロイ完了]
```

**GitHub Actions設定**:
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 20
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm run test
```

### 9.3 デプロイ手順

**自動デプロイ**:
1. `git push origin feature/xxx` → Vercel Preview生成
2. PR作成 → プレビューURLでレビュー
3. PRマージ → 本番デプロイ自動実行

**手動デプロイ**:
```bash
# Vercel CLIで本番デプロイ
vercel --prod
```

**ロールバック**:
```bash
# 前のバージョンに戻す
vercel rollback
```

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0 | 2024-01-15 | 田中太郎 | 初版作成 |
| 1.1.0 | 2024-01-18 | 田中太郎 | セキュリティ設計を詳細化 |
| 1.2.0 | 2024-01-20 | 田中太郎 | パフォーマンス最適化戦略を追加 |
