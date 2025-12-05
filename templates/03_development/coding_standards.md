# コーディング規約

## ドキュメント情報

- **作成日**: YYYY-MM-DD
- **最終更新日**: YYYY-MM-DD
- **バージョン**: 1.0.0
- **作成者**: [あなたの名前]
- **プロジェクト**: [プロジェクト名]
- **ステータス**: Draft

## 目次

- [1. 概要](#1-概要)
- [2. 全般的な規約](#2-全般的な規約)
- [3. 命名規則](#3-命名規則)
- [4. フロントエンド規約](#4-フロントエンド規約)
- [5. バックエンド規約](#5-バックエンド規約)
- [6. Git規約](#6-git規約)
- [7. コードレビュー](#7-コードレビュー)
- [変更履歴](#変更履歴)
- [関連ドキュメント](#関連ドキュメント)

## 1. 概要

### 1.1 目的

このドキュメントは、プロジェクト内でのコーディングスタイルを統一し、保守性の高いコードを書くためのガイドラインです。

### 1.2 適用範囲

本プロジェクトのすべてのソースコードに適用されます。

### 1.3 ツール

コーディング規約の遵守は以下のツールで自動化します:

- **Linter**: ESLint (JavaScript/TypeScript), Pylint/Ruff (Python)
- **Formatter**: Prettier (JavaScript/TypeScript), Black (Python)
- **型チェック**: TypeScript, mypy (Python)
- **Pre-commit Hook**: Husky + lint-staged

## 2. 全般的な規約

### 2.1 基本原則

- **可読性優先**: クリーンで読みやすいコードを書く
- **DRY原則**: Don't Repeat Yourself - 重複を避ける
- **KISS原則**: Keep It Simple, Stupid - シンプルに保つ
- **YAGNI原則**: You Aren't Gonna Need It - 必要になるまで実装しない
- **単一責任の原則**: 1つの関数/クラスは1つの責務のみを持つ

### 2.2 ファイル構成

- 1ファイルあたりの行数: 300行以下を推奨
- 関数の長さ: 50行以下を推奨
- 適切にファイルを分割し、責務を明確にする

### 2.3 コメント

**書くべきコメント**:
- 複雑なロジックの説明
- なぜそのコードが必要か (Why)
- 注意事項や制約条件

**書かないべきコメント**:
- コードを読めばわかること (What)
- 古いコードをコメントアウトしたもの (削除する)

```typescript
// Good: なぜこの処理が必要か説明
// ユーザーのタイムゾーンに合わせて日時を変換
// APIはUTCで返すため、クライアント側で変換が必要
const localDate = convertToUserTimezone(utcDate);

// Bad: コードを読めばわかる
// ユーザー名を取得する
const userName = user.name;
```

### 2.4 マジックナンバー

数値や文字列を直接コードに埋め込まず、定数として定義する。

```typescript
// Bad
if (user.age >= 18) { ... }

// Good
const ADULT_AGE = 18;
if (user.age >= ADULT_AGE) { ... }
```

## 3. 命名規則

### 3.1 基本ルール

| 対象 | 規則 | 例 |
|------|------|-----|
| 変数 | camelCase | `userName`, `isActive` |
| 定数 | UPPER_SNAKE_CASE | `MAX_COUNT`, `API_URL` |
| 関数 | camelCase | `getUserData`, `handleClick` |
| クラス | PascalCase | `UserService`, `ApiClient` |
| コンポーネント | PascalCase | `UserProfile`, `LoginForm` |
| ファイル (コンポーネント) | PascalCase | `UserProfile.tsx` |
| ファイル (その他) | kebab-case | `api-client.ts`, `utils.ts` |
| CSS クラス | kebab-case | `user-profile`, `btn-primary` |
| 型/インターフェース | PascalCase | `User`, `ApiResponse` |

### 3.2 命名のベストプラクティス

**変数名**:
```typescript
// Good: 意味が明確
const totalPrice = calculateTotal(items);
const isUserLoggedIn = checkAuthStatus();

// Bad: 意味が不明確
const tp = calc(items);
const flag = check();
```

**真偽値**:
```typescript
// Good: is, has, can などで始める
const isLoading = true;
const hasPermission = false;
const canEdit = user.role === 'admin';

// Bad
const loading = true;
const permission = false;
```

**関数名**:
```typescript
// Good: 動詞で始める
function fetchUserData() { }
function createPost() { }
function validateEmail() { }

// Bad
function userData() { }
function post() { }
function email() { }
```

**配列**:
```typescript
// Good: 複数形
const users = [];
const posts = [];

// Bad: 単数形
const user = [];
const post = [];
```

### 3.3 省略語

一般的な省略語以外は使用しない。

```typescript
// Good
const configuration = {};
const response = {};
const request = {};

// Acceptable (一般的な省略語)
const config = {};
const res = {};
const req = {};
const btn = 'button';
const img = 'image';

// Bad
const cfg = {};
const rsp = {};
```

## 4. フロントエンド規約

### 4.1 TypeScript / JavaScript

**型定義**:
```typescript
// Good: 明示的な型定義
interface User {
  id: number;
  name: string;
  email: string;
}

function getUser(id: number): User {
  // ...
}

// Bad: any型の使用
function getUser(id: any): any {
  // ...
}
```

**オプショナルチェーン**:
```typescript
// Good
const city = user?.address?.city;

// Bad
const city = user && user.address && user.address.city;
```

**分割代入**:
```typescript
// Good
const { name, email } = user;
const [first, second] = array;

// Bad
const name = user.name;
const email = user.email;
```

**アロー関数**:
```typescript
// Good: 簡潔な記述
const double = (x: number) => x * 2;

// Good: 複数行の場合
const processUser = (user: User) => {
  const validated = validateUser(user);
  return saveUser(validated);
};
```

### 4.2 React / Vue.js

**コンポーネント構造 (React)**:
```typescript
// Good: 関数コンポーネント + Hooks
import { useState } from 'react';

interface UserProfileProps {
  userId: number;
}

export function UserProfile({ userId }: UserProfileProps) {
  const [user, setUser] = useState<User | null>(null);

  // Hooks
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // Early return
  if (!user) return <Loading />;

  // Render
  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
    </div>
  );
}
```

**カスタムフック**:
```typescript
// Good: use で始める
function useUser(userId: number) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    setIsLoading(true);
    fetchUser(userId)
      .then(setUser)
      .finally(() => setIsLoading(false));
  }, [userId]);

  return { user, isLoading };
}
```

**Props の型定義**:
```typescript
// Good: interface で定義
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  onClick: () => void;
  children: React.ReactNode;
}

export function Button({
  variant = 'primary',
  size = 'md',
  onClick,
  children
}: ButtonProps) {
  // ...
}
```

### 4.3 CSS / スタイリング

**クラス名 (BEM)**:
```css
/* Good */
.user-profile { }
.user-profile__header { }
.user-profile__header--active { }

/* Bad */
.userProfile { }
.up-h { }
```

**Tailwind CSS**:
```tsx
// Good: 読みやすい順序で記述
<div className="flex items-center justify-between p-4 bg-white rounded-lg shadow">
  {/* レイアウト → スペーシング → 装飾 → その他 の順 */}
</div>

// 長い場合はclsx/classnames で分割
<div className={clsx(
  'flex items-center justify-between',
  'p-4 bg-white',
  'rounded-lg shadow',
  isActive && 'border-2 border-blue-500'
)}>
</div>
```

## 5. バックエンド規約

### 5.1 Node.js / TypeScript

**エラーハンドリング**:
```typescript
// Good: try-catch + カスタムエラー
async function getUser(id: number): Promise<User> {
  try {
    const user = await userRepository.findById(id);
    if (!user) {
      throw new NotFoundError('User not found');
    }
    return user;
  } catch (error) {
    if (error instanceof NotFoundError) {
      throw error;
    }
    throw new InternalServerError('Failed to fetch user');
  }
}

// Bad: エラーを無視
async function getUser(id: number) {
  const user = await userRepository.findById(id);
  return user; // null の可能性がある
}
```

**非同期処理**:
```typescript
// Good: async/await
async function fetchUserData() {
  const user = await getUser();
  const posts = await getPosts(user.id);
  return { user, posts };
}

// Good: 並列実行
async function fetchUserData() {
  const [user, posts] = await Promise.all([
    getUser(),
    getPosts()
  ]);
  return { user, posts };
}

// Bad: Promise チェーン
function fetchUserData() {
  return getUser()
    .then(user => getPosts(user.id)
      .then(posts => ({ user, posts }))
    );
}
```

### 5.2 API レスポンス

**統一されたレスポンス形式**:
```typescript
// Good: 統一された形式
interface ApiResponse<T> {
  data: T;
  message?: string;
}

interface ApiErrorResponse {
  error: {
    code: string;
    message: string;
    details?: any[];
  };
}

// Success
return res.json({
  data: user,
  message: 'User created successfully'
});

// Error
return res.status(400).json({
  error: {
    code: 'VALIDATION_ERROR',
    message: 'Invalid input',
    details: validationErrors
  }
});
```

### 5.3 バリデーション

```typescript
// Good: バリデーションライブラリを使用
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(2).max(100)
});

async function createUser(req: Request) {
  const validated = createUserSchema.parse(req.body);
  // ...
}
```

### 5.4 データベースクエリ

```typescript
// Good: ORM/Query Builder を使用
const users = await db.user.findMany({
  where: {
    status: 'active',
    createdAt: {
      gte: lastWeek
    }
  },
  select: {
    id: true,
    name: true,
    email: true
  },
  orderBy: {
    createdAt: 'desc'
  }
});

// Bad: 生のSQL (SQLインジェクションのリスク)
const users = await db.query(
  `SELECT * FROM users WHERE status = '${status}'`
);
```

## 6. Git規約

### 6.1 ブランチ戦略

**ブランチ名**:
```
main              # 本番環境
develop           # 開発環境 (小規模案件では不要)
feature/機能名    # 新機能開発
fix/バグ名        # バグ修正
hotfix/緊急修正   # 本番の緊急修正
```

**例**:
```
feature/user-authentication
fix/login-validation-error
hotfix/security-patch
```

### 6.2 コミットメッセージ

**フォーマット**:
```
<type>: <subject>

<body (optional)>
```

**Type**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント変更
- `style`: コードスタイル変更 (動作に影響なし)
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: ビルド設定など

**例**:
```
feat: ユーザー認証機能を追加

- JWT認証を実装
- ログイン/ログアウトAPI作成
- 認証ミドルウェア追加

fix: メール送信時のエラーを修正

SMTP設定が正しく読み込まれていなかった問題を修正

refactor: ユーザーサービスを整理

- 関数を小さく分割
- 型定義を改善
- テストを追加
```

**ベストプラクティス**:
- 1行目は50文字以内
- 現在形で書く ("追加した" ではなく "追加")
- 何を変更したか明確に
- なぜ変更したかを本文に記述

### 6.3 プルリクエスト

**タイトル**:
```
[feat] ユーザー認証機能の実装
[fix] ログインエラーの修正
[refactor] API クライアントのリファクタリング
```

**説明テンプレート**:
```markdown
## 概要
このPRの目的を簡潔に説明

## 変更内容
- 変更点1
- 変更点2

## 確認事項
- [ ] テストを追加/更新した
- [ ] ドキュメントを更新した
- [ ] Lintエラーがない

## スクリーンショット (UI変更の場合)
![image](...)

## 関連Issue
Closes #123
```

## 7. コードレビュー

### 7.1 レビューの観点

**機能性**:
- [ ] 要件を満たしているか
- [ ] バグがないか
- [ ] エッジケースを考慮しているか

**コード品質**:
- [ ] 読みやすいか
- [ ] 適切に関数/クラスが分割されているか
- [ ] 命名規則に従っているか
- [ ] 重複がないか

**セキュリティ**:
- [ ] SQLインジェクション対策されているか
- [ ] XSS対策されているか
- [ ] 認証/認可が適切か
- [ ] 機密情報がログに出力されていないか

**パフォーマンス**:
- [ ] 無駄な処理がないか
- [ ] N+1問題がないか
- [ ] 適切にキャッシュされているか

**テスト**:
- [ ] テストが書かれているか
- [ ] テストが通るか
- [ ] エッジケースのテストがあるか

### 7.2 レビューコメント

**Good**:
```
提案: ここは `map` より `filter` + `map` の方が読みやすいかもしれません。

```typescript
// Before
const result = items.map(item => item.active ? item.name : null).filter(Boolean);

// After
const result = items.filter(item => item.active).map(item => item.name);
```
```

**質問**:
```
質問: この処理は必要ですか? 上の行で既に同じことをしているように見えます。
```

**重要**:
```
重要: ここでユーザー入力をそのままSQLに渡しているので、SQLインジェクションの脆弱性があります。
プリペアドステートメントを使用してください。
```

### 7.3 レビュー時のマナー

- 攻撃的な表現を避ける
- 具体的な改善案を提示する
- 良い点も指摘する
- 「なぜ」を明確にする
- コードではなく、コードの書き方について議論する

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0     | YYYY-MM-DD | [あなたの名前] | 初版作成 |

## 関連ドキュメント

- [開発環境構築手順書](./development_setup.md)
- [システム設計書](../02_design/system_design.md)
- [技術仕様書](./technical_specification.md)
