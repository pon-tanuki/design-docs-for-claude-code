# API仕様書 - タスク管理アプリ「TaskFlow」

## ドキュメント情報

- **作成日**: 2024-01-17
- **最終更新日**: 2024-01-21
- **バージョン**: 1.2.0
- **作成者**: 田中太郎（フリーランス開発者）
- **プロジェクト**: TaskFlow - シンプルなタスク管理アプリ
- **ステータス**: Approved
- **関連ドキュメント**: [システム設計書](./system_design_example.md), [データベース設計書](./database_design_example.md)

## 目次

- [1. API概要](#1-api概要)
- [2. 共通仕様](#2-共通仕様)
- [3. 認証API](#3-認証api)
- [4. タスクAPI](#4-タスクapi)
- [5. タグAPI](#5-タグapi)
- [6. ユーザーAPI](#6-ユーザーapi)
- [7. エラーハンドリング](#7-エラーハンドリング)
- [8. レート制限](#8-レート制限)
- [変更履歴](#変更履歴)

## 1. API概要

### 1.1 基本情報

- **APIタイプ**: RESTful API
- **ベースURL**: `https://taskflow.example.com/api`
- **認証方式**: JWT（JSON Web Token）via NextAuth.js
- **データフォーマット**: JSON
- **文字コード**: UTF-8
- **HTTPバージョン**: HTTP/2

### 1.2 エンドポイント一覧

| カテゴリ | メソッド | エンドポイント | 説明 | 認証 |
|---------|---------|---------------|------|------|
| **認証** | POST | `/auth/register` | ユーザー登録 | ❌ |
|  | POST | `/auth/signin` | ログイン | ❌ |
|  | POST | `/auth/signout` | ログアウト | ✅ |
| **タスク** | GET | `/tasks` | タスク一覧取得 | ✅ |
|  | POST | `/tasks` | タスク作成 | ✅ |
|  | GET | `/tasks/:id` | タスク詳細取得 | ✅ |
|  | PATCH | `/tasks/:id` | タスク更新 | ✅ |
|  | DELETE | `/tasks/:id` | タスク削除 | ✅ |
| **タグ** | GET | `/tags` | タグ一覧取得 | ✅ |
|  | POST | `/tags` | タグ作成 | ✅ |
|  | DELETE | `/tags/:id` | タグ削除 | ✅ |
| **ユーザー** | GET | `/users/me` | 自分の情報取得 | ✅ |
|  | PATCH | `/users/me` | プロフィール更新 | ✅ |

### 1.3 ステータスコード

| コード | 説明 | 使用例 |
|-------|------|--------|
| 200 | OK | 取得・更新成功 |
| 201 | Created | 作成成功 |
| 204 | No Content | 削除成功 |
| 400 | Bad Request | バリデーションエラー |
| 401 | Unauthorized | 認証エラー |
| 403 | Forbidden | 権限エラー |
| 404 | Not Found | リソース不存在 |
| 429 | Too Many Requests | レート制限 |
| 500 | Internal Server Error | サーバーエラー |

## 2. 共通仕様

### 2.1 リクエストヘッダー

```http
Content-Type: application/json
Accept: application/json
Cookie: next-auth.session-token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2.2 レスポンス形式

#### 成功レスポンス

```json
{
  "success": true,
  "data": {
    // リソースデータ
  }
}
```

#### エラーレスポンス

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に誤りがあります",
    "details": [
      {
        "field": "title",
        "message": "タイトルは必須です"
      }
    ]
  }
}
```

### 2.3 ページネーション

```http
GET /api/tasks?page=1&limit=20
```

**レスポンス**:
```json
{
  "success": true,
  "data": {
    "tasks": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "totalPages": 8,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

### 2.4 フィルタリング・ソート

```http
GET /api/tasks?status=TODO&priority=HIGH&sort=dueDate&order=asc
```

**パラメータ**:
- `status`: タスクステータス（TODO/IN_PROGRESS/DONE）
- `priority`: 優先度（LOW/MEDIUM/HIGH）
- `sort`: ソートキー（createdAt/updatedAt/dueDate/priority）
- `order`: ソート順（asc/desc）

## 3. 認証API

### 3.1 ユーザー登録

**エンドポイント**: `POST /api/auth/register`

**リクエスト**:
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "山田花子",
  "email": "yamada@example.com",
  "password": "SecurePass123!"
}
```

**バリデーション**:
```typescript
import { z } from 'zod';

const registerSchema = z.object({
  name: z.string().min(1, "名前は必須です").max(50),
  email: z.string().email("有効なメールアドレスを入力してください"),
  password: z.string()
    .min(8, "パスワードは8文字以上必要です")
    .regex(/[A-Z]/, "大文字を1文字以上含めてください")
    .regex(/[0-9]/, "数字を1文字以上含めてください")
});
```

**レスポンス** (201 Created):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clh1a2b3c4d5e6f7g8h9",
      "name": "山田花子",
      "email": "yamada@example.com",
      "createdAt": "2024-01-20T10:30:00.000Z"
    }
  }
}
```

**エラー例** (400 Bad Request):
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に誤りがあります",
    "details": [
      {
        "field": "email",
        "message": "このメールアドレスは既に登録されています"
      }
    ]
  }
}
```

### 3.2 ログイン

**エンドポイント**: `POST /api/auth/signin`

**リクエスト**:
```http
POST /api/auth/signin
Content-Type: application/json

{
  "email": "yamada@example.com",
  "password": "SecurePass123!"
}
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clh1a2b3c4d5e6f7g8h9",
      "name": "山田花子",
      "email": "yamada@example.com"
    }
  }
}
```

**Set-Cookie ヘッダー**:
```http
Set-Cookie: next-auth.session-token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...; Path=/; HttpOnly; Secure; SameSite=Lax
```

**エラー例** (401 Unauthorized):
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "メールアドレスまたはパスワードが正しくありません"
  }
}
```

### 3.3 ログアウト

**エンドポイント**: `POST /api/auth/signout`

**リクエスト**:
```http
POST /api/auth/signout
Cookie: next-auth.session-token=...
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "message": "ログアウトしました"
}
```

## 4. タスクAPI

### 4.1 タスク一覧取得

**エンドポイント**: `GET /api/tasks`

**リクエスト**:
```http
GET /api/tasks?status=TODO&priority=HIGH&page=1&limit=20
Cookie: next-auth.session-token=...
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "data": {
    "tasks": [
      {
        "id": "clt1a2b3c4d5e6f7g8h9",
        "title": "API設計書作成",
        "description": "REST APIの仕様書をまとめる",
        "status": "TODO",
        "priority": "HIGH",
        "dueDate": "2024-01-25T17:00:00.000Z",
        "createdAt": "2024-01-20T10:00:00.000Z",
        "updatedAt": "2024-01-20T10:00:00.000Z",
        "tags": [
          {
            "id": "cltg5e6f7g8h9i0j1k",
            "name": "ドキュメント",
            "color": "#8B5CF6"
          }
        ]
      },
      {
        "id": "clt2b3c4d5e6f7g8h9i0",
        "title": "ログイン画面実装",
        "description": "NextAuthを使った認証画面",
        "status": "TODO",
        "priority": "HIGH",
        "dueDate": "2024-01-26T17:00:00.000Z",
        "createdAt": "2024-01-20T11:00:00.000Z",
        "updatedAt": "2024-01-20T11:00:00.000Z",
        "tags": [
          {
            "id": "cltg1a2b3c4d5e6f7g8",
            "name": "フロントエンド",
            "color": "#10B981"
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 2,
      "totalPages": 1,
      "hasNext": false,
      "hasPrev": false
    }
  }
}
```

**実装例**:
```typescript
// app/api/tasks/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const querySchema = z.object({
  status: z.enum(['TODO', 'IN_PROGRESS', 'DONE']).optional(),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH']).optional(),
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
  sort: z.enum(['createdAt', 'updatedAt', 'dueDate', 'priority']).default('createdAt'),
  order: z.enum(['asc', 'desc']).default('desc'),
});

export async function GET(req: NextRequest) {
  // 認証チェック
  const session = await getServerSession(authOptions);
  if (!session?.user?.id) {
    return NextResponse.json(
      { success: false, error: { code: 'UNAUTHORIZED', message: '認証が必要です' } },
      { status: 401 }
    );
  }

  // クエリパラメータ解析
  const searchParams = req.nextUrl.searchParams;
  const query = querySchema.parse(Object.fromEntries(searchParams));

  // WHERE条件構築
  const where: any = { userId: session.user.id };
  if (query.status) where.status = query.status;
  if (query.priority) where.priority = query.priority;

  // ページネーション
  const skip = (query.page - 1) * query.limit;

  // データ取得
  const [tasks, total] = await Promise.all([
    prisma.task.findMany({
      where,
      skip,
      take: query.limit,
      orderBy: { [query.sort]: query.order },
      include: {
        taskTags: {
          include: { tag: true }
        }
      }
    }),
    prisma.task.count({ where })
  ]);

  // タグ情報を整形
  const tasksWithTags = tasks.map(task => ({
    ...task,
    tags: task.taskTags.map(tt => tt.tag),
    taskTags: undefined
  }));

  return NextResponse.json({
    success: true,
    data: {
      tasks: tasksWithTags,
      pagination: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages: Math.ceil(total / query.limit),
        hasNext: skip + query.limit < total,
        hasPrev: query.page > 1
      }
    }
  });
}
```

### 4.2 タスク作成

**エンドポイント**: `POST /api/tasks`

**リクエスト**:
```http
POST /api/tasks
Content-Type: application/json
Cookie: next-auth.session-token=...

{
  "title": "ユニットテスト作成",
  "description": "Jest + React Testing Library",
  "status": "TODO",
  "priority": "MEDIUM",
  "dueDate": "2024-01-30T17:00:00.000Z",
  "tagIds": ["cltg4d5e6f7g8h9i0j"]
}
```

**バリデーション**:
```typescript
const createTaskSchema = z.object({
  title: z.string().min(1, "タイトルは必須です").max(255),
  description: z.string().max(5000).optional(),
  status: z.enum(['TODO', 'IN_PROGRESS', 'DONE']).default('TODO'),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH']).default('MEDIUM'),
  dueDate: z.string().datetime().optional(),
  tagIds: z.array(z.string()).optional()
});
```

**レスポンス** (201 Created):
```json
{
  "success": true,
  "data": {
    "task": {
      "id": "clt3c4d5e6f7g8h9i0j1",
      "title": "ユニットテスト作成",
      "description": "Jest + React Testing Library",
      "status": "TODO",
      "priority": "MEDIUM",
      "dueDate": "2024-01-30T17:00:00.000Z",
      "createdAt": "2024-01-20T12:00:00.000Z",
      "updatedAt": "2024-01-20T12:00:00.000Z",
      "tags": [
        {
          "id": "cltg4d5e6f7g8h9i0j",
          "name": "テスト",
          "color": "#EF4444"
        }
      ]
    }
  }
}
```

**実装例**:
```typescript
// app/api/tasks/route.ts
export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.id) {
    return NextResponse.json(
      { success: false, error: { code: 'UNAUTHORIZED', message: '認証が必要です' } },
      { status: 401 }
    );
  }

  const body = await req.json();
  const data = createTaskSchema.parse(body);

  // タスク作成（タグとの関連も作成）
  const task = await prisma.task.create({
    data: {
      title: data.title,
      description: data.description,
      status: data.status,
      priority: data.priority,
      dueDate: data.dueDate ? new Date(data.dueDate) : null,
      userId: session.user.id,
      taskTags: {
        create: data.tagIds?.map(tagId => ({ tagId })) || []
      }
    },
    include: {
      taskTags: {
        include: { tag: true }
      }
    }
  });

  return NextResponse.json(
    {
      success: true,
      data: {
        task: {
          ...task,
          tags: task.taskTags.map(tt => tt.tag),
          taskTags: undefined
        }
      }
    },
    { status: 201 }
  );
}
```

### 4.3 タスク詳細取得

**エンドポイント**: `GET /api/tasks/:id`

**リクエスト**:
```http
GET /api/tasks/clt1a2b3c4d5e6f7g8h9
Cookie: next-auth.session-token=...
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "data": {
    "task": {
      "id": "clt1a2b3c4d5e6f7g8h9",
      "title": "API設計書作成",
      "description": "REST APIの仕様書をまとめる",
      "status": "TODO",
      "priority": "HIGH",
      "dueDate": "2024-01-25T17:00:00.000Z",
      "createdAt": "2024-01-20T10:00:00.000Z",
      "updatedAt": "2024-01-20T10:00:00.000Z",
      "tags": [
        {
          "id": "cltg5e6f7g8h9i0j1k",
          "name": "ドキュメント",
          "color": "#8B5CF6"
        }
      ]
    }
  }
}
```

**エラー例** (404 Not Found):
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "タスクが見つかりません"
  }
}
```

**エラー例** (403 Forbidden):
```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "このタスクにアクセスする権限がありません"
  }
}
```

### 4.4 タスク更新

**エンドポイント**: `PATCH /api/tasks/:id`

**リクエスト**:
```http
PATCH /api/tasks/clt1a2b3c4d5e6f7g8h9
Content-Type: application/json
Cookie: next-auth.session-token=...

{
  "status": "IN_PROGRESS",
  "description": "REST APIの仕様書をまとめる（Postman使用）"
}
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "data": {
    "task": {
      "id": "clt1a2b3c4d5e6f7g8h9",
      "title": "API設計書作成",
      "description": "REST APIの仕様書をまとめる（Postman使用）",
      "status": "IN_PROGRESS",
      "priority": "HIGH",
      "dueDate": "2024-01-25T17:00:00.000Z",
      "createdAt": "2024-01-20T10:00:00.000Z",
      "updatedAt": "2024-01-21T09:30:00.000Z",
      "tags": [
        {
          "id": "cltg5e6f7g8h9i0j1k",
          "name": "ドキュメント",
          "color": "#8B5CF6"
        }
      ]
    }
  }
}
```

### 4.5 タスク削除

**エンドポイント**: `DELETE /api/tasks/:id`

**リクエスト**:
```http
DELETE /api/tasks/clt1a2b3c4d5e6f7g8h9
Cookie: next-auth.session-token=...
```

**レスポンス** (204 No Content):
```
(レスポンスボディなし)
```

**実装例**:
```typescript
// app/api/tasks/[id]/route.ts
export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.id) {
    return NextResponse.json(
      { success: false, error: { code: 'UNAUTHORIZED', message: '認証が必要です' } },
      { status: 401 }
    );
  }

  // タスクの所有者確認
  const task = await prisma.task.findUnique({
    where: { id: params.id },
    select: { userId: true }
  });

  if (!task) {
    return NextResponse.json(
      { success: false, error: { code: 'NOT_FOUND', message: 'タスクが見つかりません' } },
      { status: 404 }
    );
  }

  if (task.userId !== session.user.id) {
    return NextResponse.json(
      { success: false, error: { code: 'FORBIDDEN', message: 'このタスクを削除する権限がありません' } },
      { status: 403 }
    );
  }

  // 削除（task_tagsはCASCADE削除）
  await prisma.task.delete({
    where: { id: params.id }
  });

  return new NextResponse(null, { status: 204 });
}
```

## 5. タグAPI

### 5.1 タグ一覧取得

**エンドポイント**: `GET /api/tags`

**リクエスト**:
```http
GET /api/tags
Cookie: next-auth.session-token=...
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "data": {
    "tags": [
      {
        "id": "cltg1a2b3c4d5e6f7g8",
        "name": "フロントエンド",
        "color": "#10B981",
        "taskCount": 5
      },
      {
        "id": "cltg2b3c4d5e6f7g8h",
        "name": "バックエンド",
        "color": "#3B82F6",
        "taskCount": 3
      },
      {
        "id": "cltg3c4d5e6f7g8h9i",
        "name": "デザイン",
        "color": "#F59E0B",
        "taskCount": 2
      }
    ]
  }
}
```

### 5.2 タグ作成

**エンドポイント**: `POST /api/tags`

**リクエスト**:
```http
POST /api/tags
Content-Type: application/json
Cookie: next-auth.session-token=...

{
  "name": "リファクタリング",
  "color": "#8B5CF6"
}
```

**レスポンス** (201 Created):
```json
{
  "success": true,
  "data": {
    "tag": {
      "id": "cltg6f7g8h9i0j1k2l",
      "name": "リファクタリング",
      "color": "#8B5CF6",
      "createdAt": "2024-01-21T10:00:00.000Z"
    }
  }
}
```

### 5.3 タグ削除

**エンドポイント**: `DELETE /api/tags/:id`

**リクエスト**:
```http
DELETE /api/tags/cltg6f7g8h9i0j1k2l
Cookie: next-auth.session-token=...
```

**レスポンス** (204 No Content):
```
(レスポンスボディなし)
```

## 6. ユーザーAPI

### 6.1 自分の情報取得

**エンドポイント**: `GET /api/users/me`

**リクエスト**:
```http
GET /api/users/me
Cookie: next-auth.session-token=...
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clh1a2b3c4d5e6f7g8h9",
      "name": "山田花子",
      "email": "yamada@example.com",
      "image": null,
      "createdAt": "2024-01-10T09:00:00.000Z",
      "stats": {
        "totalTasks": 15,
        "completedTasks": 8,
        "inProgressTasks": 3,
        "todoTasks": 4
      }
    }
  }
}
```

### 6.2 プロフィール更新

**エンドポイント**: `PATCH /api/users/me`

**リクエスト**:
```http
PATCH /api/users/me
Content-Type: application/json
Cookie: next-auth.session-token=...

{
  "name": "山田花子（開発）",
  "image": "https://example.com/avatar.png"
}
```

**レスポンス** (200 OK):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clh1a2b3c4d5e6f7g8h9",
      "name": "山田花子（開発）",
      "email": "yamada@example.com",
      "image": "https://example.com/avatar.png",
      "updatedAt": "2024-01-21T11:00:00.000Z"
    }
  }
}
```

## 7. エラーハンドリング

### 7.1 エラーコード一覧

| コード | HTTPステータス | 説明 | 対処方法 |
|-------|---------------|------|---------|
| VALIDATION_ERROR | 400 | バリデーションエラー | リクエスト内容を修正 |
| UNAUTHORIZED | 401 | 認証エラー | ログインし直す |
| INVALID_CREDENTIALS | 401 | ログイン情報が不正 | メール/パスワード確認 |
| FORBIDDEN | 403 | 権限エラー | リソースの所有者のみ操作可能 |
| NOT_FOUND | 404 | リソース不存在 | IDを確認 |
| CONFLICT | 409 | リソース重複 | 既存リソースを確認 |
| RATE_LIMIT_EXCEEDED | 429 | レート制限 | しばらく待つ |
| INTERNAL_ERROR | 500 | サーバーエラー | 管理者に連絡 |

### 7.2 エラーハンドリング実装例

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number,
    public details?: any
  ) {
    super(message);
  }
}

export class ValidationError extends AppError {
  constructor(details: any[]) {
    super('VALIDATION_ERROR', '入力内容に誤りがあります', 400, details);
  }
}

export class UnauthorizedError extends AppError {
  constructor() {
    super('UNAUTHORIZED', '認証が必要です', 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'アクセス権限がありません') {
    super('FORBIDDEN', message, 403);
  }
}

export class NotFoundError extends AppError {
  constructor(resource = 'リソース') {
    super('NOT_FOUND', `${resource}が見つかりません`, 404);
  }
}

// グローバルエラーハンドラー
export function handleError(error: unknown) {
  if (error instanceof AppError) {
    return NextResponse.json(
      {
        success: false,
        error: {
          code: error.code,
          message: error.message,
          details: error.details
        }
      },
      { status: error.statusCode }
    );
  }

  // Zodバリデーションエラー
  if (error instanceof z.ZodError) {
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: '入力内容に誤りがあります',
          details: error.errors.map(e => ({
            field: e.path.join('.'),
            message: e.message
          }))
        }
      },
      { status: 400 }
    );
  }

  // 予期しないエラー
  console.error('Unexpected error:', error);
  return NextResponse.json(
    {
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'サーバーエラーが発生しました'
      }
    },
    { status: 500 }
  );
}
```

## 8. レート制限

### 8.1 制限値

| エンドポイント | 制限 | 期間 |
|--------------|------|------|
| `/auth/register` | 5リクエスト | 1時間 |
| `/auth/signin` | 10リクエスト | 1時間 |
| その他の認証済みAPI | 100リクエスト | 1分 |

### 8.2 レスポンスヘッダー

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705824000
```

### 8.3 レート制限超過時

**レスポンス** (429 Too Many Requests):
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "リクエスト数が制限を超えました。しばらくお待ちください",
    "retryAfter": 60
  }
}
```

### 8.4 実装例（Upstash Redis使用）

```typescript
// lib/rate-limit.ts
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
});

export const ratelimit = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(100, '1 m'), // 100 requests per minute
  analytics: true,
});

// ミドルウェアとして使用
export async function checkRateLimit(identifier: string) {
  const { success, limit, remaining, reset } = await ratelimit.limit(identifier);

  if (!success) {
    throw new AppError(
      'RATE_LIMIT_EXCEEDED',
      'リクエスト数が制限を超えました',
      429,
      { retryAfter: Math.ceil((reset - Date.now()) / 1000) }
    );
  }

  return { limit, remaining, reset };
}
```

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0 | 2024-01-17 | 田中太郎 | 初版作成 |
| 1.1.0 | 2024-01-19 | 田中太郎 | タグAPI追加 |
| 1.2.0 | 2024-01-21 | 田中太郎 | エラーハンドリング、レート制限を詳細化 |
