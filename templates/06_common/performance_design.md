# パフォーマンス設計書

## ドキュメント情報

- **作成日**: YYYY-MM-DD
- **最終更新日**: YYYY-MM-DD
- **バージョン**: 1.0.0
- **作成者**: [あなたの名前]
- **プロジェクト**: [プロジェクト名]
- **ステータス**: Draft

## 目次

- [1. 概要](#1-概要)
- [2. パフォーマンス要件](#2-パフォーマンス要件)
- [3. フロントエンドパフォーマンス](#3-フロントエンドパフォーマンス)
- [4. バックエンドパフォーマンス](#4-バックエンドパフォーマンス)
- [5. データベースパフォーマンス](#5-データベースパフォーマンス)
- [6. ネットワークとインフラ](#6-ネットワークとインフラ)
- [7. 監視と測定](#7-監視と測定)
- [8. 負荷テスト](#8-負荷テスト)
- [9. 最適化計画](#9-最適化計画)
- [変更履歴](#変更履歴)
- [関連ドキュメント](#関連ドキュメント)

## 1. 概要

### 1.1 目的

このドキュメントは、システムのパフォーマンス要件と最適化戦略を定義します。

### 1.2 パフォーマンスの重要性

**ユーザー体験への影響**:
- ページ読み込みが1秒遅れると、コンバージョン率が7%低下
- 3秒以上かかると、53%のユーザーが離脱
- モバイルユーザーは特に速度に敏感

**ビジネスへの影響**:
- SEOランキング (Core Web Vitals)
- ユーザー満足度
- サーバーコスト

### 1.3 最適化の優先順位

```
高優先度:
1. 初期表示速度 (Time to First Byte, FCP)
2. インタラクティブ性 (TTI, FID)
3. 視覚的安定性 (CLS)

中優先度:
4. APIレスポンスタイム
5. データベースクエリ速度
6. バンドルサイズ

低優先度:
7. 管理画面のパフォーマンス
8. 非同期処理の速度
```

## 2. パフォーマンス要件

### 2.1 パフォーマンス目標

| 指標 | 目標値 | 許容値 | 測定方法 |
|------|--------|--------|----------|
| **LCP (Largest Contentful Paint)** | 2.5秒以内 | 4.0秒以内 | Lighthouse |
| **FID (First Input Delay)** | 100ms以内 | 300ms以内 | Lighthouse |
| **CLS (Cumulative Layout Shift)** | 0.1以下 | 0.25以下 | Lighthouse |
| **TTFB (Time to First Byte)** | 600ms以内 | 1.0秒以内 | WebPageTest |
| **Speed Index** | 3.0秒以内 | 5.0秒以内 | Lighthouse |
| **Total Blocking Time** | 200ms以内 | 600ms以内 | Lighthouse |

**Lighthouse スコア目標**:
- Performance: 90点以上
- Accessibility: 90点以上
- Best Practices: 90点以上
- SEO: 90点以上

### 2.2 APIパフォーマンス要件

| エンドポイント | 目標 | 許容値 | 備考 |
|---------------|------|--------|------|
| `GET /api/users` | 200ms | 500ms | ページネーション付き |
| `POST /api/users` | 300ms | 800ms | バリデーション含む |
| `GET /api/posts` | 150ms | 400ms | キャッシュ有効時 |
| `POST /api/upload` | 2秒 | 5秒 | 5MBファイルまで |
| `GET /api/search` | 500ms | 1秒 | 全文検索 |

### 2.3 データベースパフォーマンス要件

| 項目 | 目標値 | 許容値 |
|------|--------|--------|
| 単純なSELECT | 10ms以内 | 50ms以内 |
| JOINを含むクエリ | 50ms以内 | 200ms以内 |
| INSERTクエリ | 20ms以内 | 100ms以内 |
| UPDATEクエリ | 30ms以内 | 150ms以内 |
| 全文検索 | 200ms以内 | 500ms以内 |

### 2.4 パフォーマンスバジェット

**JavaScript バンドルサイズ**:
- 初期バンドル: 200KB以下 (gzip圧縮後)
- 遅延ロード可能な部分: 各100KB以下
- 合計: 500KB以下

**画像**:
- ヒーロー画像: 200KB以下 (WebP)
- サムネイル: 20KB以下
- アイコン: SVGまたは5KB以下

**CSS**:
- クリティカルCSS: 14KB以下 (gzip圧縮後)
- 全体CSS: 50KB以下

**フォント**:
- Webフォント: 100KB以下 (WOFF2)
- フォント数: 2種類まで

## 3. フロントエンドパフォーマンス

### 3.1 Next.js 最適化

**App Router の活用**:
```typescript
// app/posts/page.tsx
export const revalidate = 3600; // ISR: 1時間ごとに再生成

export async function generateStaticParams() {
  // 静的生成するパスを指定
  const posts = await getPosts();
  return posts.map((post) => ({
    slug: post.slug,
  }));
}

export default async function PostsPage() {
  const posts = await getPosts(); // サーバー側でデータ取得
  return <PostList posts={posts} />;
}
```

**画像最適化**:
```typescript
import Image from 'next/image';

// ✅ Good: Next.js Image コンポーネント
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority // LCP対策
  placeholder="blur"
  blurDataURL="data:image/..." // 低解像度プレースホルダー
/>

// ❌ Bad: 通常の img タグ
<img src="/hero.jpg" alt="Hero" />
```

**動的インポート (Code Splitting)**:
```typescript
import dynamic from 'next/dynamic';

// 重いコンポーネントを遅延ロード
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <Spinner />,
  ssr: false, // クライアント側でのみレンダリング
});

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <HeavyChart data={data} />
    </div>
  );
}
```

**フォントの最適化**:
```typescript
// app/layout.tsx
import { Inter, Noto_Sans_JP } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap', // フォント読み込み中もテキストを表示
  variable: '--font-inter',
});

const notoSansJP = Noto_Sans_JP({
  subsets: ['japanese'],
  display: 'swap',
  variable: '--font-noto-sans-jp',
});

export default function RootLayout({ children }) {
  return (
    <html lang="ja" className={`${inter.variable} ${notoSansJP.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

### 3.2 React パフォーマンス最適化

**メモ化**:
```typescript
import { memo, useMemo, useCallback } from 'react';

// コンポーネントのメモ化
const UserCard = memo(({ user }: { user: User }) => {
  return <div>{user.name}</div>;
});

// 値のメモ化
function UserList({ users, filter }: Props) {
  const filteredUsers = useMemo(() => {
    return users.filter((user) => user.role === filter);
  }, [users, filter]);

  // 関数のメモ化
  const handleClick = useCallback((userId: number) => {
    console.log(`Clicked user ${userId}`);
  }, []);

  return (
    <div>
      {filteredUsers.map((user) => (
        <UserCard key={user.id} user={user} onClick={handleClick} />
      ))}
    </div>
  );
}
```

**仮想スクロール (長いリスト対策)**:
```typescript
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50, // 各行の高さ
  });

  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px` }}>
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.index}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

**遅延読み込み (Lazy Loading)**:
```typescript
import { Suspense, lazy } from 'react';

// タブで切り替わるコンポーネントを遅延ロード
const ProfileTab = lazy(() => import('./ProfileTab'));
const SettingsTab = lazy(() => import('./SettingsTab'));
const BillingTab = lazy(() => import('./BillingTab'));

function UserDashboard({ activeTab }: Props) {
  return (
    <Suspense fallback={<Spinner />}>
      {activeTab === 'profile' && <ProfileTab />}
      {activeTab === 'settings' && <SettingsTab />}
      {activeTab === 'billing' && <BillingTab />}
    </Suspense>
  );
}
```

### 3.3 CSS パフォーマンス

**Tailwind CSS の最適化**:
```javascript
// tailwind.config.js
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
  // 本番環境で未使用のクラスを削除
  purge: {
    enabled: process.env.NODE_ENV === 'production',
  },
};
```

**クリティカルCSSの抽出**:
```typescript
// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        {/* インラインでクリティカルCSSを配置 */}
        <style dangerouslySetInnerHTML={{ __html: criticalCSS }} />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

### 3.4 リソース最適化

**画像フォーマット**:
- WebP: 主要ブラウザで対応、JPEGより25-35%小さい
- AVIF: さらに小さいが対応ブラウザが限定的
- フォールバック: JPEG/PNG

```html
<picture>
  <source srcset="image.avif" type="image/avif" />
  <source srcset="image.webp" type="image/webp" />
  <img src="image.jpg" alt="Description" />
</picture>
```

**リソースヒント**:
```html
<!-- 重要なリソースを事前読み込み -->
<link rel="preload" href="/fonts/font.woff2" as="font" type="font/woff2" crossorigin />

<!-- DNSルックアップを事前実行 -->
<link rel="dns-prefetch" href="https://api.example.com" />

<!-- 次のページを事前読み込み -->
<link rel="prefetch" href="/dashboard" />
```

## 4. バックエンドパフォーマンス

### 4.1 APIレスポンス最適化

**N+1問題の解決**:
```typescript
// ❌ Bad: N+1問題
const posts = await prisma.post.findMany();
for (const post of posts) {
  const author = await prisma.user.findUnique({ where: { id: post.authorId } });
  // ...
}

// ✅ Good: include で一度に取得
const posts = await prisma.post.findMany({
  include: {
    author: true,
    comments: true,
  },
});
```

**ページネーション**:
```typescript
// Cursor-based pagination (大規模データに適している)
export async function getPosts(cursor?: number, limit = 20) {
  return await prisma.post.findMany({
    take: limit,
    skip: cursor ? 1 : 0,
    cursor: cursor ? { id: cursor } : undefined,
    orderBy: {
      createdAt: 'desc',
    },
  });
}

// API レスポンス
{
  "data": [...],
  "nextCursor": 123,
  "hasMore": true
}
```

**レスポンスの圧縮**:
```typescript
import compression from 'compression';
import express from 'express';

const app = express();

// Gzip圧縮を有効化
app.use(compression({
  level: 6, // 圧縮レベル (1-9)
  threshold: 1024, // 1KB以上のレスポンスのみ圧縮
}));
```

**HTTPキャッシュ**:
```typescript
// Next.js API Route
export async function GET(request: Request) {
  const posts = await getPosts();

  return NextResponse.json(posts, {
    headers: {
      'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=7200',
    },
  });
}
```

### 4.2 キャッシング戦略

**階層的キャッシング**:
```
1. CDN キャッシュ (Vercel Edge Network)
   ↓ ミス
2. アプリケーションキャッシュ (Redis)
   ↓ ミス
3. データベースクエリキャッシュ
   ↓ ミス
4. データベース
```

**Redisキャッシュ (導入時)**:
```typescript
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

// キャッシュの取得または設定
async function getCachedUser(userId: number): Promise<User> {
  const cacheKey = `user:${userId}`;

  // キャッシュから取得
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }

  // DBから取得
  const user = await prisma.user.findUnique({ where: { id: userId } });

  // キャッシュに保存 (有効期限: 1時間)
  await redis.setex(cacheKey, 3600, JSON.stringify(user));

  return user;
}

// キャッシュの無効化
async function invalidateUserCache(userId: number) {
  await redis.del(`user:${userId}`);
}
```

**Next.js のキャッシング**:
```typescript
// unstable_cache を使ったデータキャッシング
import { unstable_cache } from 'next/cache';

const getCachedPosts = unstable_cache(
  async () => {
    return await prisma.post.findMany();
  },
  ['posts'],
  {
    revalidate: 3600, // 1時間
    tags: ['posts'],
  }
);

// タグベースの再検証
import { revalidateTag } from 'next/cache';

export async function createPost(data: PostData) {
  await prisma.post.create({ data });

  // posts タグのキャッシュを無効化
  revalidateTag('posts');
}
```

### 4.3 非同期処理

**バックグラウンドジョブ**:
```typescript
// 重い処理は非同期で実行
import { Queue } from 'bullmq';

const emailQueue = new Queue('email', {
  connection: {
    host: 'localhost',
    port: 6379,
  },
});

// APIではジョブをキューに追加するだけ
export async function POST(request: Request) {
  const { email, subject, body } = await request.json();

  // ジョブを追加 (すぐにレスポンスを返す)
  await emailQueue.add('send-email', {
    email,
    subject,
    body,
  });

  return NextResponse.json({ message: 'Email queued' });
}

// ワーカーで実際の処理を実行
const worker = new Worker('email', async (job) => {
  await sendEmail(job.data);
});
```

## 5. データベースパフォーマンス

### 5.1 インデックス戦略

**インデックスの追加**:
```sql
-- よく検索されるカラムにインデックス
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- 複合インデックス
CREATE INDEX idx_posts_author_status ON posts(author_id, status);

-- 部分インデックス
CREATE INDEX idx_posts_published ON posts(created_at)
WHERE status = 'published';

-- 全文検索インデックス
CREATE INDEX idx_posts_title_search ON posts
USING GIN (to_tsvector('japanese', title));
```

**Prisma でのインデックス定義**:
```prisma
model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String
  authorId  Int
  status    String
  createdAt DateTime @default(now())

  author    User     @relation(fields: [authorId], references: [id])

  @@index([authorId])
  @@index([createdAt(sort: Desc)])
  @@index([authorId, status])
}
```

### 5.2 クエリ最適化

**EXPLAINによる分析**:
```sql
EXPLAIN ANALYZE
SELECT p.*, u.name as author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published'
ORDER BY p.created_at DESC
LIMIT 20;
```

**スロークエリの検出**:
```sql
-- pg_stat_statements で遅いクエリを確認
SELECT
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;
```

**クエリの最適化例**:
```typescript
// ❌ Bad: 全データを取得してからフィルタ
const allPosts = await prisma.post.findMany();
const publishedPosts = allPosts.filter(p => p.status === 'published');

// ✅ Good: DBレベルでフィルタ
const publishedPosts = await prisma.post.findMany({
  where: { status: 'published' },
});

// ❌ Bad: 不要なカラムも取得
const users = await prisma.user.findMany();

// ✅ Good: 必要なカラムのみ取得
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
  },
});
```

### 5.3 コネクションプーリング

**Prisma のコネクションプール設定**:
```env
# .env
DATABASE_URL="postgresql://user:password@localhost:5432/mydb?connection_limit=10&pool_timeout=20"
```

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

### 5.4 定期メンテナンス

**VACUUM と ANALYZE**:
```sql
-- テーブルの肥大化を防ぐ
VACUUM FULL posts;

-- 統計情報を更新してクエリプランナーを最適化
ANALYZE posts;

-- 両方を実行
VACUUM FULL ANALYZE posts;
```

**自動VACUUM設定**:
```sql
-- 自動VACUUMの設定確認
SHOW autovacuum;

-- テーブル単位での設定
ALTER TABLE posts SET (autovacuum_vacuum_scale_factor = 0.1);
```

## 6. ネットワークとインフラ

### 6.1 CDNの活用

**Vercel Edge Network**:
- 自動的にグローバルに配信
- 静的ファイルは自動的にキャッシュ
- Edge Functions で動的コンテンツも高速化

**キャッシュ戦略**:
```typescript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: '/images/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      {
        source: '/:path*.js',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
    ];
  },
};
```

### 6.2 アセットの最適化

**静的ファイルの圧縮**:
```bash
# 画像の圧縮
npm install sharp

# スクリプトで一括圧縮
node scripts/optimize-images.js
```

```typescript
// scripts/optimize-images.ts
import sharp from 'sharp';
import { readdir } from 'fs/promises';

const inputDir = './public/images';
const outputDir = './public/images/optimized';

const images = await readdir(inputDir);

for (const image of images) {
  await sharp(`${inputDir}/${image}`)
    .resize(1920, null, { withoutEnlargement: true })
    .webp({ quality: 85 })
    .toFile(`${outputDir}/${image.replace(/\.\w+$/, '.webp')}`);
}
```

### 6.3 サーバーレス最適化

**コールドスタート対策**:
```typescript
// 初期化を関数外で実行
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

export async function GET(request: Request) {
  // prisma はすでに初期化済み
  const users = await prisma.user.findMany();
  return NextResponse.json(users);
}
```

**関数のサイズ削減**:
```javascript
// next.config.js
module.exports = {
  experimental: {
    outputFileTracingRoot: path.join(__dirname, '../../'),
  },
};
```

## 7. 監視と測定

### 7.1 パフォーマンス監視ツール

**必須ツール**:
1. **Lighthouse** (無料)
   - Core Web Vitals の測定
   - パフォーマンススコア
   - 改善提案

2. **WebPageTest** (無料)
   - 詳細なウォーターフォール
   - 複数地点からのテスト
   - 動画記録

3. **Vercel Analytics** (無料枠あり)
   - Real User Monitoring (RUM)
   - Core Web Vitals
   - デプロイごとの比較

4. **Sentry** (無料枠あり)
   - エラー監視
   - パフォーマンス監視
   - トランザクショントレース

**オプション (予算がある場合)**:
- Datadog: 総合監視
- New Relic: APM
- LogRocket: セッションリプレイ

### 7.2 監視設定

**Vercel Analytics の導入**:
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

**カスタムメトリクス**:
```typescript
import { sendToAnalytics } from '@/lib/analytics';

export function measureApiCall<T>(
  name: string,
  fn: () => Promise<T>
): Promise<T> {
  const start = performance.now();

  return fn().then(
    (result) => {
      const duration = performance.now() - start;
      sendToAnalytics({
        metric: 'api_call',
        name,
        duration,
        status: 'success',
      });
      return result;
    },
    (error) => {
      const duration = performance.now() - start;
      sendToAnalytics({
        metric: 'api_call',
        name,
        duration,
        status: 'error',
      });
      throw error;
    }
  );
}

// 使用例
const users = await measureApiCall('getUsers', () => getUsers());
```

### 7.3 アラート設定

**監視項目とアラート閾値**:
```yaml
# アラート設定 (例: Vercel Monitoring)
alerts:
  - name: "Page Load Time"
    metric: "lcp"
    threshold: 4000  # 4秒
    comparison: ">"

  - name: "API Response Time"
    metric: "api_response_time"
    threshold: 1000  # 1秒
    comparison: ">"

  - name: "Error Rate"
    metric: "error_rate"
    threshold: 5  # 5%
    comparison: ">"
```

## 8. 負荷テスト

### 8.1 負荷テスト計画

**テストシナリオ**:
1. **通常負荷**: 同時ユーザー 10人
2. **ピーク負荷**: 同時ユーザー 100人
3. **ストレステスト**: 同時ユーザー 500人

**テスト対象**:
- トップページ
- ログイン・登録
- ダッシュボード
- データ検索
- API エンドポイント

### 8.2 負荷テストツール

**k6 (推奨)**:
```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 10 },   // ウォームアップ
    { duration: '3m', target: 100 },  // 通常負荷
    { duration: '1m', target: 200 },  // ピーク負荷
    { duration: '1m', target: 0 },    // クールダウン
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95パーセンタイルが500ms以下
    http_req_failed: ['rate<0.01'],   // エラー率1%以下
  },
};

export default function () {
  // トップページ
  let res = http.get('https://example.com');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);

  // API リクエスト
  res = http.get('https://example.com/api/posts');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });

  sleep(1);
}
```

**実行**:
```bash
# k6 のインストール
brew install k6  # macOS
# または
choco install k6  # Windows

# テスト実行
k6 run load-test.js

# クラウドで実行 (より現実的なテスト)
k6 cloud load-test.js
```

### 8.3 負荷テスト結果の分析

**合格基準**:
- レスポンスタイム (95パーセンタイル): 500ms以下
- エラー率: 1%以下
- スループット: 100 req/s 以上
- CPU使用率: 80%以下
- メモリ使用率: 80%以下

**報告テンプレート**:
```markdown
## 負荷テスト結果

**テスト日時**: YYYY-MM-DD HH:MM

**テスト条件**:
- 最大同時ユーザー: 200
- テスト時間: 6分
- シナリオ: 通常の閲覧・検索

**結果**:
| 指標 | 結果 | 目標 | 合否 |
|------|------|------|------|
| 平均レスポンスタイム | 320ms | 500ms以下 | ✅ |
| 95パーセンタイル | 480ms | 500ms以下 | ✅ |
| 最大レスポンスタイム | 1.2秒 | 2秒以下 | ✅ |
| エラー率 | 0.2% | 1%以下 | ✅ |
| スループット | 150 req/s | 100 req/s以上 | ✅ |

**ボトルネック**:
1. データベースクエリ時間: 平均150ms
   - 対策: インデックスの追加、クエリの最適化

**推奨事項**:
- 現状のインフラで200同時ユーザーまで対応可能
- 500ユーザーを超える場合はスケールアップが必要
```

## 9. 最適化計画

### 9.1 最適化の優先順位

**フェーズ1 (リリース前)**:
- [ ] Lighthouse スコア 90点以上
- [ ] バンドルサイズ 200KB以下
- [ ] LCP 2.5秒以内
- [ ] データベースインデックスの設定
- [ ] 画像の最適化 (WebP化)

**フェーズ2 (リリース後1ヶ月)**:
- [ ] Redisキャッシュの導入
- [ ] CDNキャッシュの最適化
- [ ] APIレスポンスタイム 200ms以内
- [ ] 不要なJavaScriptの削除

**フェーズ3 (リリース後3ヶ月)**:
- [ ] エッジコンピューティングの活用
- [ ] 画像CDNの導入
- [ ] データベースのパーティショニング
- [ ] 全文検索の最適化

### 9.2 継続的な改善

**月次レビュー**:
```markdown
## パフォーマンスレビュー (YYYY-MM)

**Core Web Vitals**:
- LCP: 2.1秒 (目標: 2.5秒以内) ✅
- FID: 80ms (目標: 100ms以内) ✅
- CLS: 0.05 (目標: 0.1以下) ✅

**改善項目**:
1. [ ] トップページのバンドルサイズを150KBに削減
2. [ ] ダッシュボードのAPIレスポンスタイムを改善
3. [ ] 画像の遅延読み込みを実装

**次月の目標**:
- Lighthouse スコア 95点以上
- APIレスポンスタイム平均 150ms以下
```

### 9.3 パフォーマンスチェックリスト

**リリース前チェックリスト**:
- [ ] Lighthouse スコア 90点以上
- [ ] バンドルサイズがバジェット内
- [ ] 画像が最適化されている (WebP, サイズ適切)
- [ ] フォントが最適化されている (WOFF2, preload)
- [ ] 不要なJavaScriptが削除されている
- [ ] データベースインデックスが設定されている
- [ ] APIレスポンスタイムが目標値以内
- [ ] キャッシュが適切に設定されている
- [ ] 負荷テストに合格
- [ ] モバイル表示が最適化されている

**定期チェック (月次)**:
- [ ] Real User Monitoring データのレビュー
- [ ] スロークエリの確認と最適化
- [ ] 不要なログ・データの削除
- [ ] サーバーリソースの使用率確認
- [ ] エラー率の確認
- [ ] ユーザーフィードバックの確認

## 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|-----------|------|--------|----------|
| 1.0.0     | YYYY-MM-DD | [あなたの名前] | 初版作成 |

## 関連ドキュメント

- [システム設計書](../02_design/system_design.md)
- [技術仕様書](../03_development/technical_specification.md)
- [運用手順書](../05_operation/operation_manual.md)
- [セキュリティ設計書](./security_design.md)
