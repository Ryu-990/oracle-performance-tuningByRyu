-- ================================================================
-- 基本的な使用例
-- @author RyuHazako
-- ================================================================

-- 1. システムの初期化
-- テーブル、シーケンス、インデックスを作成
@sql/schema/tables.sql
@sql/schema/sequences.sql
@sql/schema/indexes.sql

-- ファンクションとプロシージャを作成
@sql/functions/your_function.sql
@sql/functions/validate_user_data.sql
@sql/functions/calculate_order_amount.sql
@sql/procedures/register_user.sql
@sql/procedures/process_order.sql
@sql/procedures/cleanup_test_data.sql
@sql/procedures/insert_test_data.sql

-- 最適化コンポーネントを作成
@sql/optimization/analyze_index_statistics.sql
@sql/optimization/collect_index_usage_stats.sql
@sql/optimization/should_optimize_index.sql
@sql/optimization/optimize_index.sql
@sql/optimization/daily_index_optimization_batch.sql

-- ビューとスケジューラを作成
@sql/views/v_index_optimization_report.sql
@sql/scheduler/daily_optimization_job.sql

-- 2. テストデータの投入
EXEC insert_test_data;

-- 3. 基本的な操作例
DECLARE
    v_user_id NUMBER;
    v_order_id NUMBER;
    v_result VARCHAR2(100);
BEGIN
    -- ユーザー登録
    register_user('山田太郎', 'yamada@example.com', v_user_id, v_result);
    DBMS_OUTPUT.PUT_LINE('ユーザー登録: ' || v_result || ' (ID: ' || v_user_id || ')');
    
    -- 注文処理
    process_order(v_user_id, 1, 5, v_order_id, v_result);
    DBMS_OUTPUT.PUT_LINE('注文処理: ' || v_result || ' (注文ID: ' || v_order_id || ')');
    
    -- ファンクション使用例
    DBMS_OUTPUT.PUT_LINE('メッセージ: ' || your_function('山田太郎', 1));
    DBMS_OUTPUT.PUT_LINE('ユーザー検証: ' || validate_user_data(v_user_id, 'yamada@example.com'));
END;
/