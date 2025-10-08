# インデックス最適化ガイド

@author RyuHazako

## 概要

このドキュメントでは、Oracleデータベースにおけるインデックス最適化の戦略と実装について詳しく説明します。

## インデックス最適化の基本原則

### 1. インデックスの健全性指標

- **B-treeレベル (BLEVEL)**: 3以下が理想、4以上は再構築を検討
- **クラスタリング係数**: テーブル行数の10%以下が理想
- **リーフブロック数**: 使用頻度と比較して適切なサイズ
- **統計情報の新しさ**: 1週間以内に更新されていることが推奨

### 2. 最適化アクション

- **REBUILD**: インデックスを完全に再構築（断片化解消）
- **COALESCE**: 隣接する空きスペースを結合（軽量な最適化）
- **ANALYZE**: 統計情報の更新
- **DROP**: 使用されていないインデックスの削除

## 実装されたシステム

### 統計情報収集システム

- `analyze_index_statistics`: インデックスの詳細統計を収集
- `collect_index_usage_stats`: 実際の使用状況を追跡

### 最適化判定システム

- `should_optimize_index`: 複数の要素を考慮した最適化推奨
- 判定基準：
  - 統計情報の古さ
  - インデックスの使用頻度
  - B-treeレベル
  - クラスタリング係数

### 自動最適化システム

- `optimize_index`: 指定された最適化を実行
- `daily_index_optimization_batch`: 日次バッチ処理
- Oracle Schedulerによる自動実行

## 使用方法

### 手動最適化

```sql
-- インデックス統計の分析
SELECT analyze_index_statistics('USER_DATA', 'IDX_USER_EMAIL') FROM DUAL;

-- 最適化推奨の確認
SELECT should_optimize_index('USER_DATA', 'IDX_USER_EMAIL') FROM DUAL;

-- 最適化実行
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  optimize_index('USER_DATA', 'IDX_USER_EMAIL', 'REBUILD', v_result);
  DBMS_OUTPUT.PUT_LINE('結果: ' || v_result);
END;
/
```

### 自動最適化

- 毎日午前2時に自動実行
- 設定テーブル `index_optimization_config` で制御
- 実行結果は `index_optimization_log` に記録

## モニタリング

### レポートビュー

```sql
-- 健全性レポート
SELECT * FROM v_index_optimization_report 
ORDER BY health_status;
```

### ログの確認

```sql
-- 最適化履歴
SELECT * FROM index_optimization_log 
WHERE execution_date >= SYSDATE - 7;

-- システムログ
SELECT * FROM system_log 
WHERE function_name LIKE '%index%' 
AND log_timestamp >= SYSDATE - 1;
```

## ベストプラクティス

1. **定期的な統計更新**: 週1回以上
2. **使用状況の監視**: 月1回の詳細分析
3. **閾値の調整**: システム特性に応じた設定
4. **メンテナンス時間**: 低負荷時間での実行
5. **バックアップ**: 最適化前の状態保存

## トラブルシューティング

### よくある問題

1. **統計情報が古い**
   - 解決策: ANALYZE実行

2. **使用されていないインデックス**
   - 解決策: DROP検討

3. **高いクラスタリング係数**
   - 解決策: REBUILD実行

4. **深いB-treeレベル**
   - 解決策: REBUILD実行

### パフォーマンス問題

- 最適化処理の実行時間監視
- リソース使用量の確認
- 並行処理への影響評価