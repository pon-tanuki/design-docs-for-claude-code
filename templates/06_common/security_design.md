# セキュリティ設計書

## ドキュメント情報

- **作成日**: YYYY-MM-DD
- **最終更新日**: YYYY-MM-DD
- **バージョン**: 1.0.0
- **作成者**: [あなたの名前]
- **プロジェクト**: [プロジェクト名]
- **ステータス**: Draft

## 目次

- [1. 概要](#1-概要)
- [2. セキュリティ要件](#2-セキュリティ要件)
- [3. 認証・認可](#3-認証認可)
- [4. データ保護](#4-データ保護)
- [5. 脆弱性対策](#5-脆弱性対策)
- [6. セキュリティテスト](#6-セキュリティテスト)
- [7. インシデント対応](#7-インシデント対応)
- [8. セキュリティチェックリスト](#8-セキュリティチェックリスト)
- [変更履歴](#変更履歴)
- [関連ドキュメント](#関連ドキュメント)

## 1. 概要

### 1.1 目的

このドキュメントは、システムのセキュリティ設計と対策を定義します。

### 1.2 セキュリティポリシー

**基本方針**:
- すべてのユーザーデータを保護する
- 最小権限の原則を適用する
- 多層防御を実装する
- セキュリティバイデザインを実践する

### 1.3 対象範囲

- Webアプリケーション
- API
- データベース
- インフラストラクチャ

## 2. セキュリティ要件

### 2.1 機密性 (Confidentiality)

| 要件 | 実装方法 |
|------|---------|
| データの暗号化 | HTTPS、データベース暗号化 |
| アクセス制御 | JWT認証、ロールベース認可 |
| 機密情報の保護 | 環境変数、暗号化保存 |

### 2.2 完全性 (Integrity)

| 要件 | 実装方法 |
|------|---------|
| データの改ざん防止 | トランザクション、バリデーション |
| 入力検証 | クライアント・サーバー両方で実施 |
| 監査ログ | 重要な操作を記録 |

### 2.3 可用性 (Availability)

| 要件 | 実装方法 |
|------|---------|
| DoS対策 | レート制限、WAF |
| バックアップ | 日次自動バックアップ |
| 冗長化 | クラウドプラットフォームの冗長性 |

## 3. 認証・認可

### 3.1 認証方式

**JWT (JSON Web Token) 認証**:

```typescript
// トークン生成
const token = jwt.sign(
  {
    userId: user.id,
    email: user.email,
    role: user.role
  },
  process.env.JWT_SECRET!,
  {
    expiresIn: '1h',
    issuer: 'example.com',
    audience: 'example.com'
  }
);
```

**セキュリティ設定**:
- 有効期限: 1時間
- リフレッシュトークン: 7日間
- トークン署名: HS256またはRS256
- シークレットキー: 32文字以上のランダム文字列

### 3.2 パスワードポリシー

**要件**:
- 最小長: 8文字
- 含むべき文字種:
  - 英大文字
  - 英小文字
  - 数字
  - 記号 (推奨)

**実装**:
```typescript
const passwordSchema = z.string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain uppercase letter')
  .regex(/[a-z]/, 'Password must contain lowercase letter')
  .regex(/[0-9]/, 'Password must contain number');
```

**パスワードハッシュ化**:
```typescript
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 10;

// ハッシュ化
const hash = await bcrypt.hash(password, SALT_ROUNDS);

// 検証
const isValid = await bcrypt.compare(password, hash);
```

### 3.3 セッション管理

**セキュリティ設定**:
- HttpOnly Cookie: 有効化 (XSS対策)
- Secure Cookie: 有効化 (HTTPS必須)
- SameSite: Strict または Lax
- セッションタイムアウト: 30分 (無操作時)

```typescript
res.cookie('token', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 3600000 // 1時間
});
```

### 3.4 認可 (Authorization)

**ロールベースアクセス制御 (RBAC)**:

| ロール | 権限 |
|-------|------|
| Guest | 閲覧のみ |
| User | CRUD操作 (自分のデータのみ) |
| Admin | すべての操作 |

**実装例**:
```typescript
function requireRole(...allowedRoles: string[]) {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        error: { code: 'FORBIDDEN', message: 'Insufficient permissions' }
      });
    }
    next();
  };
}

// 使用例
router.delete('/users/:id', requireRole('admin'), deleteUser);
```

## 4. データ保護

### 4.1 データ分類

| 分類 | 例 | 保護レベル |
|------|-----|----------|
| 公開 | サービス情報 | 低 |
| 内部 | ログ、メトリクス | 中 |
| 機密 | ユーザー情報 | 高 |
| 極秘 | パスワード、決済情報 | 最高 |

### 4.2 暗号化

**転送中の暗号化**:
- HTTPS/TLS 1.2以上を使用
- HSTS (HTTP Strict Transport Security) を有効化
- 証明書: Let's Encrypt (自動更新)

**保存時の暗号化**:
```typescript
import crypto from 'crypto';

const algorithm = 'aes-256-gcm';
const key = Buffer.from(process.env.ENCRYPTION_KEY!, 'hex');

// 暗号化
function encrypt(text: string): string {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, key, iv);

  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  const authTag = cipher.getAuthTag();

  return iv.toString('hex') + ':' + authTag.toString('hex') + ':' + encrypted;
}

// 復号化
function decrypt(encrypted: string): string {
  const parts = encrypted.split(':');
  const iv = Buffer.from(parts[0], 'hex');
  const authTag = Buffer.from(parts[1], 'hex');
  const encryptedText = parts[2];

  const decipher = crypto.createDecipheriv(algorithm, key, iv);
  decipher.setAuthTag(authTag);

  let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}
```

### 4.3 個人情報保護

**収集する個人情報**:
- メールアドレス
- 氏名
- [その他]

**保護措置**:
- [ ] 必要最小限の収集
- [ ] 利用目的の明示
- [ ] 同意の取得
- [ ] アクセス制御
- [ ] 暗号化保存 (必要に応じて)
- [ ] 削除機能の提供

**データ保持期間**:
- アクティブユーザー: 無期限
- 退会ユーザー: 即座に削除または90日後に削除

## 5. 脆弱性対策

### 5.1 OWASP Top 10 対策

#### 1. インジェクション

**SQLインジェクション対策**:
```typescript
// NG: 生のSQL
const query = `SELECT * FROM users WHERE email = '${email}'`;

// OK: プリペアドステートメント (Prisma)
const user = await db.user.findUnique({
  where: { email }
});
```

**コマンドインジェクション対策**:
```typescript
// NG: ユーザー入力を直接実行
exec(`command ${userInput}`);

// OK: 入力をサニタイズ、またはホワイトリスト方式
const allowedCommands = ['start', 'stop'];
if (allowedCommands.includes(userInput)) {
  exec(`command ${userInput}`);
}
```

#### 2. 認証の不備

**対策**:
- [ ] 強固なパスワードポリシー
- [ ] アカウントロックアウト (5回失敗で15分ロック)
- [ ] セッションタイムアウト
- [ ] 安全なパスワードリセット

```typescript
// ログイン失敗回数の追跡
const loginAttempts = await redis.get(`login:${email}`);
if (loginAttempts && parseInt(loginAttempts) >= 5) {
  throw new Error('Account locked. Try again in 15 minutes');
}

// 失敗時にカウントアップ
await redis.setex(`login:${email}`, 900, (parseInt(loginAttempts || '0') + 1).toString());
```

#### 3. 機密データの露出

**対策**:
- [ ] 機密情報をログに出力しない
- [ ] エラーメッセージに詳細を含めない
- [ ] API レスポンスから不要な情報を削除

```typescript
// NG: パスワードを返す
return user;

// OK: パスワードを除外
const { password, ...userWithoutPassword } = user;
return userWithoutPassword;

// または Prisma で除外
const user = await db.user.findUnique({
  where: { id },
  select: {
    id: true,
    email: true,
    name: true,
    // password は含めない
  }
});
```

#### 4. XML外部エンティティ (XXE)

**対策**:
- XMLパーサーの安全な設定
- JSONを使用 (XMLを避ける)

#### 5. アクセス制御の不備

**対策**:
```typescript
// リソースの所有者チェック
async function updatePost(req: AuthRequest, res: Response) {
  const post = await db.post.findUnique({ where: { id: req.params.id } });

  if (!post) {
    return res.status(404).json({ error: 'Post not found' });
  }

  // 所有者または管理者のみ更新可能
  if (post.userId !== req.user!.userId && req.user!.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }

  // 更新処理
}
```

#### 6. セキュリティ設定のミス

**対策**:
- [ ] HTTPS強制
- [ ] セキュリティヘッダーの設定
- [ ] 不要なサービスの無効化
- [ ] デフォルトパスワードの変更

```typescript
// セキュリティヘッダー (helmet.js)
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));
```

#### 7. XSS (クロスサイトスクリプティング)

**対策**:
```typescript
// フロントエンド: React は自動でエスケープ
// ただし dangerouslySetInnerHTML は避ける

// サーバー側: サニタイズ
import DOMPurify from 'isomorphic-dompurify';

const sanitized = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['p', 'br', 'strong', 'em'],
  ALLOWED_ATTR: []
});
```

#### 8. 安全でないデシリアライゼーション

**対策**:
- 信頼できないデータをデシリアライズしない
- JSONのみ使用

#### 9. 既知の脆弱性を持つコンポーネント

**対策**:
```bash
# 定期的な脆弱性スキャン
npm audit

# 自動修正
npm audit fix

# 依存関係の更新
npm update
```

#### 10. ログとモニタリングの不足

**対策**:
```typescript
// 重要な操作をログに記録
logger.info('User login', { userId: user.id, ip: req.ip });
logger.warn('Failed login attempt', { email, ip: req.ip });
logger.error('Database error', { error: err.message });

// 監査ログ
await db.auditLog.create({
  data: {
    userId: user.id,
    action: 'DELETE_USER',
    targetId: deletedUserId,
    ip: req.ip,
    timestamp: new Date()
  }
});
```

### 5.2 CSRF対策

**SameSite Cookie**:
```typescript
res.cookie('token', token, {
  sameSite: 'strict',
  // その他の設定
});
```

**CSRFトークン (必要に応じて)**:
```typescript
import csrf from 'csurf';

const csrfProtection = csrf({ cookie: true });
app.use(csrfProtection);
```

### 5.3 レート制限

```typescript
import rateLimit from 'express-rate-limit';

// 一般API
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分
  max: 100, // 100リクエスト
  message: 'Too many requests'
});

// ログインAPI (より厳しく)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true
});

app.use('/api/', apiLimiter);
app.use('/api/auth/login', authLimiter);
```

## 6. セキュリティテスト

### 6.1 テスト項目

**認証・認可テスト**:
- [ ] 未認証でアクセスできないことを確認
- [ ] 権限のないユーザーがアクセスできないことを確認
- [ ] セッションタイムアウトが動作することを確認

**入力検証テスト**:
- [ ] SQLインジェクション
- [ ] XSS
- [ ] コマンドインジェクション
- [ ] パストラバーサル

**セキュリティヘッダーテスト**:
```bash
# securityheaders.com でチェック
curl -I https://example.com | grep -i "x-frame-options\|x-content-type-options\|strict-transport-security"
```

### 6.2 ペネトレーションテスト

**ツール**:
- OWASP ZAP
- Burp Suite Community Edition
- npm audit
- Snyk

**実施頻度**:
- リリース前: 必須
- 定期: 四半期ごと

## 7. インシデント対応

### 7.1 インシデント分類

| レベル | 定義 | 対応時間 |
|-------|------|---------|
| Critical | データ漏洩、システム侵害 | 即座 |
| High | 脆弱性の発見 | 24時間以内 |
| Medium | 軽微な脆弱性 | 1週間以内 |
| Low | セキュリティ改善 | 計画的に |

### 7.2 対応フロー

1. **検知**: ログ、監視、報告
2. **封じ込め**: 影響範囲の特定と一時的な遮断
3. **根絶**: 脆弱性の修正
4. **復旧**: サービスの再開
5. **事後分析**: 原因分析と再発防止

## 8. セキュリティチェックリスト

### 8.1 開発時

- [ ] 入力バリデーションを実装
- [ ] 出力エスケープを実装
- [ ] 認証・認可を実装
- [ ] エラーハンドリングを適切に実装
- [ ] 機密情報をハードコードしない
- [ ] セキュリティヘッダーを設定

### 8.2 デプロイ前

- [ ] セキュリティテストを実施
- [ ] 依存関係の脆弱性スキャン
- [ ] 環境変数の確認
- [ ] HTTPS設定の確認
- [ ] バックアップの確認

### 8.3 運用時

- [ ] ログの定期確認
- [ ] 脆弱性情報の確認
- [ ] 依存関係の定期更新
- [ ] アクセスログの分析
- [ ] セキュリティパッチの適用

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0     | YYYY-MM-DD | [あなたの名前] | 初版作成 |

## 関連ドキュメント

- [システム設計書](../02_design/system_design.md)
- [技術仕様書](../03_development/technical_specification.md)
- [運用手順書](../05_operation/operation_manual.md)
