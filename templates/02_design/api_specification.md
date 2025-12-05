# API仕様書

## ドキュメント情報

- **作成日**: YYYY-MM-DD
- **最終更新日**: YYYY-MM-DD
- **バージョン**: 1.0.0
- **作成者**: [あなたの名前]
- **クライアント**: [クライアント名]
- **ステータス**: Draft

## 目次

- [1. 概要](#1-概要)
- [2. 共通仕様](#2-共通仕様)
- [3. 認証API](#3-認証api)
- [4. ユーザーAPI](#4-ユーザーapi)
- [5. [機能別API]](#5-機能別api)
- [6. エラーレスポンス](#6-エラーレスポンス)
- [変更履歴](#変更履歴)
- [関連ドキュメント](#関連ドキュメント)

## 1. 概要

### 1.1 基本情報

- **ベースURL**:
  - 開発環境: `http://localhost:8000/api`
  - 本番環境: `https://api.example.com/api`
- **プロトコル**: HTTPS (本番環境)
- **データ形式**: JSON
- **文字コード**: UTF-8
- **APIバージョン**: v1

### 1.2 APIエンドポイント一覧

| カテゴリ | エンドポイント | メソッド | 説明 | 認証 |
|---------|--------------|---------|------|------|
| 認証 | `/auth/register` | POST | ユーザー登録 | 不要 |
| 認証 | `/auth/login` | POST | ログイン | 不要 |
| 認証 | `/auth/logout` | POST | ログアウト | 必要 |
| 認証 | `/auth/me` | GET | 認証ユーザー情報取得 | 必要 |
| ユーザー | `/users` | GET | ユーザー一覧取得 | 必要 |
| ユーザー | `/users/:id` | GET | ユーザー詳細取得 | 必要 |
| ユーザー | `/users/:id` | PUT | ユーザー更新 | 必要 |
| ユーザー | `/users/:id` | DELETE | ユーザー削除 | 必要 |

## 2. 共通仕様

### 2.1 リクエストヘッダー

**必須ヘッダー**:
```http
Content-Type: application/json
Accept: application/json
```

**認証が必要なエンドポイント**:
```http
Authorization: Bearer {access_token}
```

### 2.2 レスポンス形式

**成功レスポンス**:
```json
{
  "data": {
    // レスポンスデータ
  },
  "message": "Success"
}
```

**一覧取得の場合**:
```json
{
  "data": [
    // データ配列
  ],
  "pagination": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  }
}
```

**エラーレスポンス**:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーメッセージ",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### 2.3 HTTPステータスコード

| コード | 説明 | 使用例 |
|-------|------|--------|
| 200 | OK | リクエスト成功 |
| 201 | Created | リソース作成成功 |
| 204 | No Content | 削除成功 (レスポンスボディなし) |
| 400 | Bad Request | バリデーションエラー |
| 401 | Unauthorized | 認証エラー |
| 403 | Forbidden | 権限エラー |
| 404 | Not Found | リソースが見つからない |
| 409 | Conflict | リソースの競合 |
| 422 | Unprocessable Entity | バリデーションエラー |
| 429 | Too Many Requests | レート制限超過 |
| 500 | Internal Server Error | サーバーエラー |

### 2.4 ページネーション

**リクエストパラメータ**:
- `page`: ページ番号 (デフォルト: 1)
- `limit`: 1ページあたりの件数 (デフォルト: 20, 最大: 100)

**例**:
```
GET /api/users?page=2&limit=50
```

### 2.5 ソート

**リクエストパラメータ**:
- `sort`: ソートフィールド
- `order`: ソート順 (asc/desc)

**例**:
```
GET /api/users?sort=created_at&order=desc
```

### 2.6 フィルタリング

**例**:
```
GET /api/posts?status=published&user_id=123
```

### 2.7 レート制限

- 認証済みユーザー: 100リクエスト/分
- 未認証: 20リクエスト/分

**レスポンスヘッダー**:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

## 3. 認証API

### 3.1 ユーザー登録

**エンドポイント**: `POST /api/auth/register`

**説明**: 新規ユーザーを登録します

**認証**: 不要

**リクエストボディ**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "山田太郎"
}
```

**リクエストパラメータ**:
| フィールド | 型 | 必須 | 説明 | バリデーション |
|----------|----|----|------|--------------|
| email | string | ○ | メールアドレス | メール形式、255文字以内 |
| password | string | ○ | パスワード | 8文字以上、英数字記号を含む |
| name | string | ○ | ユーザー名 | 2-100文字 |

**レスポンス (201 Created)**:
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "山田太郎",
      "created_at": "2024-01-01T00:00:00Z"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

**エラーレスポンス**:
- 400: バリデーションエラー
- 409: メールアドレスが既に登録済み

---

### 3.2 ログイン

**エンドポイント**: `POST /api/auth/login`

**説明**: ユーザー認証を行い、アクセストークンを発行します

**認証**: 不要

**リクエストボディ**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**リクエストパラメータ**:
| フィールド | 型 | 必須 | 説明 |
|----------|----|----|------|
| email | string | ○ | メールアドレス |
| password | string | ○ | パスワード |

**レスポンス (200 OK)**:
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "山田太郎",
      "role": "user"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

**エラーレスポンス**:
- 401: メールアドレスまたはパスワードが正しくありません

---

### 3.3 ログアウト

**エンドポイント**: `POST /api/auth/logout`

**説明**: 現在のセッションを無効化します

**認証**: 必要

**リクエストヘッダー**:
```http
Authorization: Bearer {access_token}
```

**レスポンス (200 OK)**:
```json
{
  "message": "Successfully logged out"
}
```

---

### 3.4 認証ユーザー情報取得

**エンドポイント**: `GET /api/auth/me`

**説明**: 現在認証されているユーザーの情報を取得します

**認証**: 必要

**レスポンス (200 OK)**:
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "山田太郎",
    "role": "user",
    "profile": {
      "bio": "こんにちは",
      "avatar_url": "https://example.com/avatar.jpg"
    },
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

## 4. ユーザーAPI

### 4.1 ユーザー一覧取得

**エンドポイント**: `GET /api/users`

**説明**: ユーザー一覧を取得します

**認証**: 必要

**クエリパラメータ**:
| パラメータ | 型 | 必須 | デフォルト | 説明 |
|----------|----|----|---------|------|
| page | integer | - | 1 | ページ番号 |
| limit | integer | - | 20 | 1ページあたりの件数 (最大100) |
| search | string | - | - | 名前・メールで検索 |
| role | string | - | - | ロールでフィルタ (user/admin) |

**リクエスト例**:
```
GET /api/users?page=1&limit=20&search=山田&role=user
```

**レスポンス (200 OK)**:
```json
{
  "data": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "山田太郎",
      "role": "user",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  }
}
```

---

### 4.2 ユーザー詳細取得

**エンドポイント**: `GET /api/users/:id`

**説明**: 指定したIDのユーザー詳細情報を取得します

**認証**: 必要

**パスパラメータ**:
| パラメータ | 型 | 説明 |
|----------|-----|------|
| id | integer | ユーザーID |

**リクエスト例**:
```
GET /api/users/123
```

**レスポンス (200 OK)**:
```json
{
  "data": {
    "id": 123,
    "email": "user@example.com",
    "name": "山田太郎",
    "role": "user",
    "profile": {
      "bio": "こんにちは",
      "avatar_url": "https://example.com/avatar.jpg",
      "website": "https://example.com"
    },
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

**エラーレスポンス**:
- 404: ユーザーが見つかりません

---

### 4.3 ユーザー更新

**エンドポイント**: `PUT /api/users/:id`

**説明**: ユーザー情報を更新します

**認証**: 必要（本人または管理者のみ）

**パスパラメータ**:
| パラメータ | 型 | 説明 |
|----------|-----|------|
| id | integer | ユーザーID |

**リクエストボディ**:
```json
{
  "name": "山田花子",
  "profile": {
    "bio": "プロフィール更新",
    "avatar_url": "https://example.com/new-avatar.jpg"
  }
}
```

**リクエストパラメータ**:
| フィールド | 型 | 必須 | 説明 |
|----------|----|----|------|
| name | string | - | ユーザー名 (2-100文字) |
| profile.bio | string | - | 自己紹介 (500文字以内) |
| profile.avatar_url | string | - | アバターURL |

**レスポンス (200 OK)**:
```json
{
  "data": {
    "id": 123,
    "email": "user@example.com",
    "name": "山田花子",
    "profile": {
      "bio": "プロフィール更新",
      "avatar_url": "https://example.com/new-avatar.jpg"
    },
    "updated_at": "2024-01-02T00:00:00Z"
  }
}
```

**エラーレスポンス**:
- 403: 権限がありません
- 404: ユーザーが見つかりません

---

### 4.4 ユーザー削除

**エンドポイント**: `DELETE /api/users/:id`

**説明**: ユーザーを削除します

**認証**: 必要（本人または管理者のみ）

**パスパラメータ**:
| パラメータ | 型 | 説明 |
|----------|-----|------|
| id | integer | ユーザーID |

**レスポンス (204 No Content)**:
レスポンスボディなし

**エラーレスポンス**:
- 403: 権限がありません
- 404: ユーザーが見つかりません

## 5. [機能別API]

### 5.1 [エンドポイント名]

**エンドポイント**: `[METHOD] /api/[path]`

**説明**: [エンドポイントの説明]

**認証**: [必要/不要]

**リクエストボディ**:
```json
{
  // リクエスト例
}
```

**レスポンス**:
```json
{
  // レスポンス例
}
```

## 6. エラーレスポンス

### 6.1 エラーコード一覧

| コード | HTTPステータス | 説明 |
|-------|--------------|------|
| VALIDATION_ERROR | 400 | バリデーションエラー |
| UNAUTHORIZED | 401 | 認証エラー |
| FORBIDDEN | 403 | 権限エラー |
| NOT_FOUND | 404 | リソースが見つからない |
| CONFLICT | 409 | リソースの競合 |
| RATE_LIMIT_EXCEEDED | 429 | レート制限超過 |
| INTERNAL_ERROR | 500 | サーバー内部エラー |

### 6.2 エラーレスポンス例

**バリデーションエラー (400)**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ]
  }
}
```

**認証エラー (401)**:
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication required"
  }
}
```

**権限エラー (403)**:
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You don't have permission to access this resource"
  }
}
```

**リソースが見つからない (404)**:
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found"
  }
}
```

**レート制限超過 (429)**:
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later."
  }
}
```

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0     | YYYY-MM-DD | [あなたの名前] | 初版作成 |

## 関連ドキュメント

- [要件定義書](../01_planning/requirements_specification.md)
- [システム設計書](./system_design.md)
- [データベース設計書](./database_design.md)
