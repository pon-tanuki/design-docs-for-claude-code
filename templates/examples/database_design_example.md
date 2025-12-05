# データベース設計書 - タスク管理アプリ「TaskFlow」

## ドキュメント情報

- **作成日**: 2024-01-16
- **最終更新日**: 2024-01-19
- **バージョン**: 1.1.0
- **作成者**: 田中太郎（フリーランス開発者）
- **プロジェクト**: TaskFlow - シンプルなタスク管理アプリ
- **ステータス**: Approved
- **関連ドキュメント**: [システム設計書](./system_design_example.md), [API仕様書](./api_specification_example.md)

## 目次

- [1. データベース概要](#1-データベース概要)
- [2. ER図](#2-er図)
- [3. テーブル定義](#3-テーブル定義)
- [4. インデックス設計](#4-インデックス設計)
- [5. データ制約](#5-データ制約)
- [6. マイグレーション計画](#6-マイグレーション計画)
- [7. バックアップ・リストア](#7-バックアップリストア)
- [8. データ保持ポリシー](#8-データ保持ポリシー)
- [変更履歴](#変更履歴)

## 1. データベース概要

### 1.1 基本情報

- **DBMS**: PostgreSQL 15.x
- **ホスティング**: Supabase
- **文字コード**: UTF-8
- **タイムゾーン**: Asia/Tokyo (JST)
- **接続方式**: Prisma ORM経由

### 1.2 データ規模見積もり

| テーブル | 初期レコード数 | 1年後予測 | 増加率 | 備考 |
|---------|--------------|----------|--------|------|
| users | 10 | 50 | 月+3-5人 | 社内ユーザー |
| tasks | 100 | 6,000 | 月+500件 | 1人50件/月 |
| tags | 20 | 50 | 月+2-3件 | カテゴリタグ |
| task_tags | 200 | 12,000 | tasksに比例 | 中間テーブル |

**総容量見積もり**:
- 初期: ~10MB
- 1年後: ~100MB
- Supabase無料枠（500MB）で十分対応可能

### 1.3 テーブル一覧

| テーブル名 | 論理名 | 用途 | レコード数見込み |
|-----------|-------|------|----------------|
| users | ユーザー | ユーザー情報管理 | 50 |
| tasks | タスク | タスク情報管理 | 6,000 |
| tags | タグ | タグマスター | 50 |
| task_tags | タスク-タグ関連 | 多対多リレーション | 12,000 |
| accounts | アカウント | NextAuth認証情報 | 50 |
| sessions | セッション | セッション管理 | 10-20 |

## 2. ER図

### 2.1 論理ER図

```mermaid
erDiagram
    users ||--o{ tasks : "作成する"
    users ||--o{ accounts : "所有する"
    users ||--o{ sessions : "持つ"
    tasks }o--o{ tags : "タグ付けされる"
    tasks ||--o{ task_tags : "持つ"
    tags ||--o{ task_tags : "持つ"

    users {
        string id PK
        string name
        string email UK
        string hashedPassword
        string image
        datetime emailVerified
        datetime createdAt
        datetime updatedAt
    }

    tasks {
        string id PK
        string userId FK
        string title
        text description
        enum status
        enum priority
        datetime dueDate
        datetime createdAt
        datetime updatedAt
    }

    tags {
        string id PK
        string name UK
        string color
        datetime createdAt
        datetime updatedAt
    }

    task_tags {
        string taskId FK
        string tagId FK
        datetime createdAt
    }

    accounts {
        string id PK
        string userId FK
        string type
        string provider
        string providerAccountId
        datetime createdAt
        datetime updatedAt
    }

    sessions {
        string id PK
        string sessionToken UK
        string userId FK
        datetime expires
        datetime createdAt
        datetime updatedAt
    }
```

### 2.2 Prismaスキーマ

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ユーザーテーブル
model User {
  id              String    @id @default(cuid())
  name            String?
  email           String    @unique
  emailVerified   DateTime?
  image           String?
  hashedPassword  String?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // リレーション
  tasks           Task[]
  accounts        Account[]
  sessions        Session[]

  @@map("users")
}

// タスクテーブル
model Task {
  id          String    @id @default(cuid())
  title       String
  description String?   @db.Text
  status      Status    @default(TODO)
  priority    Priority  @default(MEDIUM)
  dueDate     DateTime?
  userId      String
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  // リレーション
  user        User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  taskTags    TaskTag[]

  // インデックス
  @@index([userId])
  @@index([userId, status])
  @@index([dueDate])
  @@map("tasks")
}

// タスクステータス列挙型
enum Status {
  TODO        // 未着手
  IN_PROGRESS // 進行中
  DONE        // 完了
}

// 優先度列挙型
enum Priority {
  LOW         // 低
  MEDIUM      // 中
  HIGH        // 高
}

// タグテーブル
model Tag {
  id        String    @id @default(cuid())
  name      String    @unique
  color     String    @default("#3B82F6") // Tailwind blue-500
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  // リレーション
  taskTags  TaskTag[]

  @@map("tags")
}

// タスク-タグ中間テーブル（多対多）
model TaskTag {
  taskId    String
  tagId     String
  createdAt DateTime @default(now())

  // リレーション
  task      Task     @relation(fields: [taskId], references: [id], onDelete: Cascade)
  tag       Tag      @relation(fields: [tagId], references: [id], onDelete: Cascade)

  @@id([taskId, tagId])
  @@map("task_tags")
}

// NextAuth用アカウントテーブル
model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String? @db.Text
  access_token      String? @db.Text
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String? @db.Text
  session_state     String?
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
  @@map("accounts")
}

// NextAuth用セッションテーブル
model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("sessions")
}
```

## 3. テーブル定義

### 3.1 users（ユーザー）

**用途**: システムユーザーの情報を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | VARCHAR(25) | NOT NULL | cuid() | ユーザーID（主キー） |
| name | VARCHAR(255) | NULL | NULL | 表示名 |
| email | VARCHAR(255) | NOT NULL | - | メールアドレス（ユニーク） |
| emailVerified | TIMESTAMP | NULL | NULL | メール検証日時 |
| image | TEXT | NULL | NULL | プロフィール画像URL |
| hashedPassword | VARCHAR(255) | NULL | NULL | ハッシュ化パスワード（bcrypt） |
| createdAt | TIMESTAMP | NOT NULL | now() | 作成日時 |
| updatedAt | TIMESTAMP | NOT NULL | now() | 更新日時 |

**制約**:
- PRIMARY KEY: `id`
- UNIQUE: `email`

**サンプルデータ**:
```sql
INSERT INTO users (id, name, email, hashedPassword, createdAt, updatedAt) VALUES
('clh1a2b3c4d5e6f7g8h9', '山田花子', 'yamada@abc.co.jp', '$2a$10$...', NOW(), NOW()),
('clh2b3c4d5e6f7g8h9i0', '佐藤次郎', 'sato@abc.co.jp', '$2a$10$...', NOW(), NOW());
```

### 3.2 tasks（タスク）

**用途**: タスク情報を管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | VARCHAR(25) | NOT NULL | cuid() | タスクID（主キー） |
| title | VARCHAR(255) | NOT NULL | - | タスク名 |
| description | TEXT | NULL | NULL | 詳細説明 |
| status | ENUM | NOT NULL | 'TODO' | ステータス（TODO/IN_PROGRESS/DONE） |
| priority | ENUM | NOT NULL | 'MEDIUM' | 優先度（LOW/MEDIUM/HIGH） |
| dueDate | TIMESTAMP | NULL | NULL | 期限日時 |
| userId | VARCHAR(25) | NOT NULL | - | 作成者ID（外部キー） |
| createdAt | TIMESTAMP | NOT NULL | now() | 作成日時 |
| updatedAt | TIMESTAMP | NOT NULL | now() | 更新日時 |

**制約**:
- PRIMARY KEY: `id`
- FOREIGN KEY: `userId` REFERENCES `users(id)` ON DELETE CASCADE
- INDEX: `userId`, `(userId, status)`, `dueDate`

**サンプルデータ**:
```sql
INSERT INTO tasks (id, title, description, status, priority, dueDate, userId, createdAt, updatedAt) VALUES
('clt1a2b3c4d5e6f7g8h9', 'API設計書作成', 'REST APIの仕様書をまとめる', 'TODO', 'HIGH', '2024-01-25 17:00:00', 'clh1a2b3c4d5e6f7g8h9', NOW(), NOW()),
('clt2b3c4d5e6f7g8h9i0', 'ログイン画面実装', 'NextAuthを使った認証画面', 'IN_PROGRESS', 'HIGH', '2024-01-26 17:00:00', 'clh1a2b3c4d5e6f7g8h9', NOW(), NOW()),
('clt3c4d5e6f7g8h9i0j1', 'ユニットテスト作成', 'Jest + React Testing Library', 'TODO', 'MEDIUM', '2024-01-30 17:00:00', 'clh2b3c4d5e6f7g8h9i0', NOW(), NOW());
```

### 3.3 tags（タグ）

**用途**: タスク分類用のタグマスター

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | VARCHAR(25) | NOT NULL | cuid() | タグID（主キー） |
| name | VARCHAR(50) | NOT NULL | - | タグ名（ユニーク） |
| color | VARCHAR(7) | NOT NULL | '#3B82F6' | カラーコード（HEX） |
| createdAt | TIMESTAMP | NOT NULL | now() | 作成日時 |
| updatedAt | TIMESTAMP | NOT NULL | now() | 更新日時 |

**制約**:
- PRIMARY KEY: `id`
- UNIQUE: `name`

**サンプルデータ**:
```sql
INSERT INTO tags (id, name, color, createdAt, updatedAt) VALUES
('cltg1a2b3c4d5e6f7g8', 'フロントエンド', '#10B981', NOW(), NOW()),
('cltg2b3c4d5e6f7g8h', 'バックエンド', '#3B82F6', NOW(), NOW()),
('cltg3c4d5e6f7g8h9i', 'デザイン', '#F59E0B', NOW(), NOW()),
('cltg4d5e6f7g8h9i0j', 'テスト', '#EF4444', NOW(), NOW()),
('cltg5e6f7g8h9i0j1k', 'ドキュメント', '#8B5CF6', NOW(), NOW());
```

### 3.4 task_tags（タスク-タグ関連）

**用途**: タスクとタグの多対多リレーション

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| taskId | VARCHAR(25) | NOT NULL | - | タスクID（複合主キー） |
| tagId | VARCHAR(25) | NOT NULL | - | タグID（複合主キー） |
| createdAt | TIMESTAMP | NOT NULL | now() | 関連付け日時 |

**制約**:
- PRIMARY KEY: `(taskId, tagId)`
- FOREIGN KEY: `taskId` REFERENCES `tasks(id)` ON DELETE CASCADE
- FOREIGN KEY: `tagId` REFERENCES `tags(id)` ON DELETE CASCADE

**サンプルデータ**:
```sql
INSERT INTO task_tags (taskId, tagId, createdAt) VALUES
('clt1a2b3c4d5e6f7g8h9', 'cltg5e6f7g8h9i0j1k', NOW()), -- API設計書作成 + ドキュメント
('clt2b3c4d5e6f7g8h9i0', 'cltg1a2b3c4d5e6f7g8', NOW()), -- ログイン画面実装 + フロントエンド
('clt3c4d5e6f7g8h9i0j1', 'cltg4d5e6f7g8h9i0j', NOW()); -- ユニットテスト作成 + テスト
```

### 3.5 accounts（NextAuth認証）

**用途**: OAuth等の外部認証プロバイダー情報

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | VARCHAR(25) | NOT NULL | cuid() | アカウントID（主キー） |
| userId | VARCHAR(25) | NOT NULL | - | ユーザーID（外部キー） |
| type | VARCHAR(255) | NOT NULL | - | アカウントタイプ（oauth/credentials） |
| provider | VARCHAR(255) | NOT NULL | - | プロバイダー名（google/github等） |
| providerAccountId | VARCHAR(255) | NOT NULL | - | プロバイダー側のID |
| refresh_token | TEXT | NULL | NULL | リフレッシュトークン |
| access_token | TEXT | NULL | NULL | アクセストークン |
| expires_at | INTEGER | NULL | NULL | トークン有効期限 |
| token_type | VARCHAR(255) | NULL | NULL | トークンタイプ |
| scope | VARCHAR(255) | NULL | NULL | スコープ |
| id_token | TEXT | NULL | NULL | IDトークン |
| session_state | VARCHAR(255) | NULL | NULL | セッション状態 |
| createdAt | TIMESTAMP | NOT NULL | now() | 作成日時 |
| updatedAt | TIMESTAMP | NOT NULL | now() | 更新日時 |

**制約**:
- PRIMARY KEY: `id`
- FOREIGN KEY: `userId` REFERENCES `users(id)` ON DELETE CASCADE
- UNIQUE: `(provider, providerAccountId)`

### 3.6 sessions（セッション管理）

**用途**: ユーザーセッション管理

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| id | VARCHAR(25) | NOT NULL | cuid() | セッションID（主キー） |
| sessionToken | VARCHAR(255) | NOT NULL | - | セッショントークン（ユニーク） |
| userId | VARCHAR(25) | NOT NULL | - | ユーザーID（外部キー） |
| expires | TIMESTAMP | NOT NULL | - | 有効期限 |
| createdAt | TIMESTAMP | NOT NULL | now() | 作成日時 |
| updatedAt | TIMESTAMP | NOT NULL | now() | 更新日時 |

**制約**:
- PRIMARY KEY: `id`
- UNIQUE: `sessionToken`
- FOREIGN KEY: `userId` REFERENCES `users(id)` ON DELETE CASCADE

## 4. インデックス設計

### 4.1 インデックス一覧

| テーブル | カラム | タイプ | 用途 | 推定削減率 |
|---------|-------|--------|------|-----------|
| users | email | UNIQUE | ログイン時のユーザー検索 | 99% |
| tasks | userId | B-tree | ユーザー別タスク一覧 | 90% |
| tasks | (userId, status) | 複合 | ステータスフィルター付き検索 | 95% |
| tasks | dueDate | B-tree | 期限順ソート、期限通知 | 80% |
| tags | name | UNIQUE | タグ名検索 | 95% |
| sessions | sessionToken | UNIQUE | セッション検証 | 99% |

### 4.2 クエリパフォーマンス

**クエリ例1**: ユーザーの進行中タスク取得
```sql
-- インデックス使用: tasks(userId, status)
SELECT * FROM tasks
WHERE userId = 'clh1a2b3c4d5e6f7g8h9'
  AND status = 'IN_PROGRESS'
ORDER BY dueDate ASC;

-- EXPLAIN結果
-- Index Scan using tasks_userId_status_idx
-- Rows: 5 / 1000 (0.5%)
```

**クエリ例2**: 明日期限のタスク検索（通知用）
```sql
-- インデックス使用: tasks(dueDate)
SELECT t.id, t.title, u.email
FROM tasks t
JOIN users u ON t.userId = u.id
WHERE t.dueDate BETWEEN '2024-01-25 00:00:00' AND '2024-01-25 23:59:59'
  AND t.status != 'DONE';

-- EXPLAIN結果
-- Index Scan using tasks_dueDate_idx
-- Rows: 10 / 1000 (1%)
```

## 5. データ制約

### 5.1 NOT NULL制約

```prisma
model Task {
  title       String    // 必須
  status      Status    // 必須（デフォルト値あり）
  priority    Priority  // 必須（デフォルト値あり）
  userId      String    // 必須（外部キー）
  description String?   // オプショナル
  dueDate     DateTime? // オプショナル
}
```

### 5.2 ユニーク制約

```sql
-- メールアドレスの重複防止
ALTER TABLE users ADD CONSTRAINT users_email_key UNIQUE (email);

-- タグ名の重複防止
ALTER TABLE tags ADD CONSTRAINT tags_name_key UNIQUE (name);

-- セッショントークンの重複防止
ALTER TABLE sessions ADD CONSTRAINT sessions_sessionToken_key UNIQUE (sessionToken);
```

### 5.3 外部キー制約（カスケード削除）

```sql
-- ユーザー削除時、関連タスクも削除
ALTER TABLE tasks
  ADD CONSTRAINT tasks_userId_fkey
  FOREIGN KEY (userId) REFERENCES users(id)
  ON DELETE CASCADE;

-- タスク削除時、タグ関連も削除
ALTER TABLE task_tags
  ADD CONSTRAINT task_tags_taskId_fkey
  FOREIGN KEY (taskId) REFERENCES tasks(id)
  ON DELETE CASCADE;

-- タグ削除時、タスクとの関連も削除
ALTER TABLE task_tags
  ADD CONSTRAINT task_tags_tagId_fkey
  FOREIGN KEY (tagId) REFERENCES tags(id)
  ON DELETE CASCADE;
```

### 5.4 CHECK制約

```sql
-- タグのカラーコードはHEX形式（#RRGGBB）
ALTER TABLE tags
  ADD CONSTRAINT tags_color_hex_check
  CHECK (color ~ '^#[0-9A-Fa-f]{6}$');

-- メールアドレスの形式チェック
ALTER TABLE users
  ADD CONSTRAINT users_email_format_check
  CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

## 6. マイグレーション計画

### 6.1 初期マイグレーション

```bash
# Prismaマイグレーション作成
npx prisma migrate dev --name init

# 生成されるマイグレーションファイル
# prisma/migrations/20240116000000_init/migration.sql
```

**マイグレーション内容**:
```sql
-- CreateEnum
CREATE TYPE "Status" AS ENUM ('TODO', 'IN_PROGRESS', 'DONE');
CREATE TYPE "Priority" AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "email" TEXT NOT NULL,
    "emailVerified" TIMESTAMP(3),
    "image" TEXT,
    "hashedPassword" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "tasks" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "status" "Status" NOT NULL DEFAULT 'TODO',
    "priority" "Priority" NOT NULL DEFAULT 'MEDIUM',
    "dueDate" TIMESTAMP(3),
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tasks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
CREATE INDEX "tasks_userId_idx" ON "tasks"("userId");
CREATE INDEX "tasks_userId_status_idx" ON "tasks"("userId", "status");
CREATE INDEX "tasks_dueDate_idx" ON "tasks"("dueDate");

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
```

### 6.2 マイグレーション実行フロー

```mermaid
graph LR
    A[スキーマ変更] --> B[prisma migrate dev]
    B --> C[migration.sql生成]
    C --> D[開発DBに適用]
    D --> E[Prisma Client再生成]
    E --> F[テスト実行]
    F --> G{テストOK?}
    G -->|Yes| H[Git commit]
    G -->|No| A
    H --> I[PR作成]
    I --> J[レビュー]
    J --> K[本番デプロイ]
    K --> L[prisma migrate deploy]
```

### 6.3 マイグレーション履歴管理

```bash
# マイグレーション状態確認
npx prisma migrate status

# マイグレーション履歴
npx prisma migrate history

# 特定のマイグレーションまでロールバック（開発環境のみ）
npx prisma migrate reset
```

## 7. バックアップ・リストア

### 7.1 Supabaseの自動バックアップ

**無料プラン**:
- 自動バックアップ: なし
- 手動バックアップ: 必要

**Proプラン（$25/月）**:
- 自動バックアップ: 毎日
- 保持期間: 7日間
- ポイントインタイムリカバリ（PITR）: 対応

### 7.2 手動バックアップスクリプト

```bash
#!/bin/bash
# backup.sh - データベースバックアップスクリプト

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"
DB_URL="postgresql://user:pass@host:5432/taskflow"

mkdir -p $BACKUP_DIR

# 全データダンプ
pg_dump $DB_URL > "$BACKUP_DIR/taskflow_$DATE.sql"

# 圧縮
gzip "$BACKUP_DIR/taskflow_$DATE.sql"

# 30日以上前のバックアップを削除
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "Backup completed: taskflow_$DATE.sql.gz"
```

**実行スケジュール（GitHub Actions）**:
```yaml
# .github/workflows/backup.yml
name: Database Backup
on:
  schedule:
    - cron: '0 3 * * *' # 毎日3:00AM (JST 12:00PM)

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Backup Database
        run: |
          pg_dump ${{ secrets.DATABASE_URL }} | gzip > backup_$(date +%Y%m%d).sql.gz
      - name: Upload to S3
        run: |
          aws s3 cp backup_$(date +%Y%m%d).sql.gz s3://taskflow-backups/
```

### 7.3 リストア手順

```bash
# バックアップファイルからリストア
gunzip -c backups/taskflow_20240120_030000.sql.gz | psql $DATABASE_URL

# Prismaマイグレーション適用（必要な場合）
npx prisma migrate deploy
```

## 8. データ保持ポリシー

### 8.1 データライフサイクル

| データ種別 | 保持期間 | 削除タイミング | 備考 |
|-----------|---------|---------------|------|
| ユーザーアカウント | 無期限 | 退会時に即座 | カスケード削除でタスクも削除 |
| タスク | 無期限 | ユーザー削除時 | 完了タスクも保持（履歴として） |
| セッション | 30日 | 有効期限切れ時 | 自動クリーンアップ |
| タグ | 無期限 | 手動削除時 | マスターデータとして保持 |
| バックアップ | 30日 | 30日経過後 | 自動削除 |

### 8.2 個人情報削除（GDPR対応）

```typescript
// lib/gdpr.ts
import { prisma } from './prisma';

/**
 * ユーザーデータの完全削除（GDPR対応）
 */
export async function deleteUserData(userId: string) {
  // カスケード削除により以下も自動削除される:
  // - tasks (userId経由)
  // - task_tags (taskId経由)
  // - accounts (userId経由)
  // - sessions (userId経由)

  await prisma.user.delete({
    where: { id: userId }
  });

  console.log(`User ${userId} and all related data deleted`);
}
```

### 8.3 期限切れセッションのクリーンアップ

```typescript
// lib/cleanup.ts
import { prisma } from './prisma';

/**
 * 期限切れセッションを削除（Cron Job）
 */
export async function cleanupExpiredSessions() {
  const result = await prisma.session.deleteMany({
    where: {
      expires: {
        lt: new Date() // 現在時刻より前
      }
    }
  });

  console.log(`Deleted ${result.count} expired sessions`);
  return result.count;
}

// Vercel Cron Jobsで毎日実行
// app/api/cron/cleanup/route.ts
export async function GET() {
  await cleanupExpiredSessions();
  return Response.json({ success: true });
}
```

**Vercel Cron設定**:
```json
// vercel.json
{
  "crons": [{
    "path": "/api/cron/cleanup",
    "schedule": "0 4 * * *"
  }]
}
```

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0 | 2024-01-16 | 田中太郎 | 初版作成 |
| 1.1.0 | 2024-01-19 | 田中太郎 | バックアップ・クリーンアップ戦略を追加 |
