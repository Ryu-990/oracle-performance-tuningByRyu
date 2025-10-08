# Oracleパフォーマンスチューニングガイドライン

@author RyuHazako

## 全体的なアプローチ

### 1. 計測とベースライン

- 現在のパフォーマンス指標を記録
- AWRレポートによる定期的な監視
- 主要なSQLクエリの実行計画確認

### 2. ボトルネック特定

#### CPU使用率
- 高CPU使用率のSQLクエリ特定
- 並列処理の最適化
- インデックスの効果的な使用

#### I/O待機
- 物理読み取りの削減
- SGA設定の最適化
- インデックスによるアクセス改善

#### メモリ使用
- バッファプールサイズの調整
- ソート領域の最適化
- 結果セットキャッシュの活用

### 3. SQLチューニング

#### インデックス戦略
- 適切なインデックス設計
- 複合インデックスの効果的な使用
- 不要なインデックスの削除

#### クエリ最適化
- WHERE句の最適化
- JOIN順序の最適化
- サブクエリの最適化

#### 統計情報管理
- 定期的な統計情報更新
- ヒストグラム生成の活用
- 統計情報の品質監視

## 具体的なチューニングテクニック

### インデックス設計

```sql
-- 複合インデックスの例
CREATE INDEX idx_order_composite 
ON order_data(order_date, order_status, user_id);

-- 関数ベースインデックス
CREATE INDEX idx_upper_email 
ON user_data(UPPER(email));

-- 部分インデックス
CREATE INDEX idx_active_orders 
ON order_data(order_date) 
WHERE order_status = 'ACTIVE';
```

### パーティショニング

```sql
-- 範囲パーティショニング
CREATE TABLE order_data_partitioned (
    order_id NUMBER,
    order_date DATE,
    ...
) PARTITION BY RANGE (order_date) (
    PARTITION p2023 VALUES LESS THAN (DATE '2024-01-01'),
    PARTITION p2024 VALUES LESS THAN (DATE '2025-01-01')
);
```

### ヒント句の活用

```sql
-- インデックスヒント
SELECT /*+ INDEX(u IDX_USER_EMAIL) */ 
* FROM user_data u WHERE email = 'test@example.com';

-- 並列処理ヒント
SELECT /*+ PARALLEL(o, 4) */ 
COUNT(*) FROM order_data o;
```

## パフォーマンス監視

### 重要な動的パフォーマンスビュー

```sql
-- 長時間実行中のSQL
SELECT sql_id, elapsed_time, executions 
FROM v$sql 
WHERE elapsed_time > 1000000
ORDER BY elapsed_time DESC;

-- セッション待機イベント
SELECT event, total_waits, time_waited 
FROM v$session_event 
WHERE sid = &session_id;

-- インデックス使用統計
SELECT name, gets, getmisses, sleeps 
FROM v$latch 
WHERE name LIKE '%cache buffers%';
```

### 実行計画の分析

```sql
-- 実行計画の確認
EXPLAIN PLAN FOR
SELECT * FROM user_data u 
JOIN order_data o ON u.id = o.user_id
WHERE u.email = 'test@example.com';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 実際の実行統計
SELECT /*+ GATHER_PLAN_STATISTICS */ 
* FROM user_data u 
JOIN order_data o ON u.id = o.user_id
WHERE u.email = 'test@example.com';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null, null, 'ALLSTATS LAST'));
```

## メンテナンス計画

### 日次タスク
- インデックス最適化バッチ実行
- 統計情報の部分更新
- ログファイルの監視

### 週次タスク
- 統計情報の完全更新
- AWRレポートの分析
- 長時間実行SQLの確認

### 月次タスク
- パフォーマンス傾向の分析
- インデックス使用状況の見直し
- システム設定の最適化

## チューニングチェックリスト

### 事前準備
- [ ] 現在のパフォーマンス測定
- [ ] 実行計画の確認
- [ ] 統計情報の状態確認

### インデックス最適化
- [ ] 不要なインデックスの特定
- [ ] 複合インデックスの検討
- [ ] インデックス統計の更新

### SQL最適化
- [ ] WHERE句の最適化
- [ ] JOIN条件の確認
- [ ] サブクエリの最適化

### システム設定
- [ ] SGA設定の確認
- [ ] PGA設定の確認
- [ ] 並列度の調整

### 継続監視
- [ ] 定期的なパフォーマンス測定
- [ ] AWRレポートの分析
- [ ] ユーザーフィードバックの収集