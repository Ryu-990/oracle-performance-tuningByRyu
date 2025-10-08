# Oracle Performance Tuning Examples

@author RyuHazako

このリポジトリは、Oracleデータベースのパフォーマンスチューニングに関する実践的なサンプルコードとベストプラクティスを提供します。特にインデックス最適化、統計情報管理、およびストアドプロシージャの効率的な実装に焦点を当てています。

## 概要

このプロジェクトには、以下の主要コンポーネントが含まれています：

- テーブル設計とインデックス戦略
- 自動インデックス最適化バッチシステム
- パフォーマンス統計収集と分析
- 効率的なストアドプロシージャとファンクション
- テストデータ生成とクリーンアップユーティリティ

## 主な機能

- **インデックス最適化システム**: クラスタリング係数、B-treeレベル、使用頻度などに基づいて、インデックスの再構築やCOALESCEを自動的に判断・実行
- **統計情報収集**: インデックスとSQLの使用状況を追跡し、最適化の判断材料を提供
- **パフォーマンスレポート**: インデックスの健全性と使用状況を可視化するビュー
- **スケジュールされたメンテナンス**: Oracle Schedulerを使用した定期的な最適化ジョブ

## プロジェクト構成

```
oracle-performance-tuning/
├── README.md
├── docs/
│   ├── index_optimization.md
│   └── performance_guidelines.md
├── sql/
│   ├── schema/
│   │   ├── tables.sql
│   │   ├── sequences.sql
│   │   └── indexes.sql
│   ├── functions/
│   │   ├── your_function.sql
│   │   ├── validate_user_data.sql
│   │   └── calculate_order_amount.sql
│   ├── procedures/
│   │   ├── register_user.sql
│   │   ├── process_order.sql
│   │   ├── cleanup_test_data.sql
│   │   └── insert_test_data.sql
│   ├── optimization/
│   │   ├── analyze_index_statistics.sql
│   │   ├── collect_index_usage_stats.sql
│   │   ├── should_optimize_index.sql
│   │   ├── optimize_index.sql
│   │   └── daily_index_optimization_batch.sql
│   ├── views/
│   │   └── v_index_optimization_report.sql
│   └── scheduler/
│       └── daily_optimization_job.sql
├── test/
│   ├── test_data.sql
│   └── performance_tests.sql
└── examples/
    ├── basic_usage.sql
    └── optimization_examples.sql
```

## インストール方法

1. リポジトリをクローンします：
   ```
   git clone https://github.com/yourusername/oracle-performance-tuning.git
   ```

2. Oracle SQLクライアント（SQL*Plus、SQL Developerなど）を使用して接続します。

3. スキーマオブジェクトを作成します：
   ```sql
   @sql/schema/tables.sql
   @sql/schema/sequences.sql
   @sql/schema/indexes.sql
   ```

4. 関数とプロシージャを作成します：
   ```sql
   @sql/functions/your_function.sql
   @sql/functions/validate_user_data.sql
   @sql/functions/calculate_order_amount.sql
   @sql/procedures/register_user.sql
   @sql/procedures/process_order.sql
   ```

5. 最適化コンポーネントをインストールします：
   ```sql
   @sql/optimization/analyze_index_statistics.sql
   @sql/optimization/collect_index_usage_stats.sql
   @sql/optimization/should_optimize_index.sql
   @sql/optimization/optimize_index.sql
   @sql/optimization/daily_index_optimization_batch.sql
   ```

6. テストデータを挿入します：
   ```sql
   @sql/procedures/insert_test_data.sql
   ```

## 使用例

### インデックス最適化の実行

```sql
-- 特定のインデックスを分析して最適化
DECLARE
  v_recommendation VARCHAR2(100);
  v_result VARCHAR2(4000);
BEGIN
  v_recommendation := should_optimize_index('USER_DATA', 'IDX_USER_EMAIL');
  
  IF v_recommendation != 'MAINTAIN' THEN
    optimize_index('USER_DATA', 'IDX_USER_EMAIL', v_recommendation, v_result);
    DBMS_OUTPUT.PUT_LINE('最適化結果: ' || v_result);
  ELSE
    DBMS_OUTPUT.PUT_LINE('最適化は不要です');
  END IF;
END;
/
```

### 最適化レポートの確認

```sql
-- インデックスの健全性レポートを表示
SELECT 
  table_name, 
  index_name, 
  health_status, 
  usage_count, 
  last_optimization,
  last_optimization_date
FROM 
  v_index_optimization_report
ORDER BY 
  CASE health_status
    WHEN 'STALE_STATS' THEN 1
    WHEN 'HIGH_COST' THEN 2
    WHEN 'UNUSED' THEN 3
    WHEN 'HEALTHY' THEN 4
  END;
```

## 技術的詳細

- **インデックス最適化アルゴリズム**: クラスタリング係数、B-treeレベル、リーフブロック数、使用頻度などの複数の要素を考慮して最適化の必要性を判断します。
- **統計情報収集**: Oracle動的パフォーマンスビュー（V$SQL_PLANなど）を活用して、インデックスの実際の使用状況を追跡します。
- **スケジューリング**: Oracle Schedulerを使用して、低負荷時間帯に定期的な最適化ジョブを実行します。

## ベストプラクティス

- インデックスの統計情報は定期的に更新する
- 使用されていないインデックスを特定し、削除を検討する
- クラスタリング係数が高いインデックスは再構築を検討する
- B-treeレベルが4以上のインデックスは再構築を検討する
- 断片化したインデックスはCOALESCEを実行する

## ライセンス

MITライセンス

## 貢献

プルリクエストは歓迎します。大きな変更を加える前には、まずissueを開いて議論してください。

---

このプロジェクトは、Oracleデータベースのパフォーマンスチューニングに関する実践的な知識と経験を共有することを目的としています。実際の本番環境に適用する前に、十分なテストを行ってください。