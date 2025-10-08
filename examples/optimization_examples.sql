-- ================================================================
-- インデックス最適化の実践例
-- @author RyuHazako
-- ================================================================

-- 1. インデックス統計収集の例
DECLARE
    v_stat_id NUMBER;
BEGIN
    -- 各テーブルのインデックス統計を収集
    v_stat_id := analyze_index_statistics('USER_DATA', 'IDX_USER_EMAIL');
    DBMS_OUTPUT.PUT_LINE('USER_DATA.IDX_USER_EMAIL 統計ID: ' || v_stat_id);
    
    v_stat_id := analyze_index_statistics('PRODUCT_DATA', 'IDX_PRODUCT_CATEGORY');
    DBMS_OUTPUT.PUT_LINE('PRODUCT_DATA.IDX_PRODUCT_CATEGORY 統計ID: ' || v_stat_id);
    
    v_stat_id := analyze_index_statistics('ORDER_DATA', 'IDX_ORDER_USER');
    DBMS_OUTPUT.PUT_LINE('ORDER_DATA.IDX_ORDER_USER 統計ID: ' || v_stat_id);
END;
/

-- 2. インデックス最適化判定の例
DECLARE
    v_recommendation VARCHAR2(100);
BEGIN
    -- 各インデックスの最適化推奨を確認
    v_recommendation := should_optimize_index('USER_DATA', 'IDX_USER_EMAIL');
    DBMS_OUTPUT.PUT_LINE('IDX_USER_EMAIL 推奨: ' || v_recommendation);
    
    v_recommendation := should_optimize_index('PRODUCT_DATA', 'IDX_PRODUCT_CATEGORY');
    DBMS_OUTPUT.PUT_LINE('IDX_PRODUCT_CATEGORY 推奨: ' || v_recommendation);
    
    v_recommendation := should_optimize_index('ORDER_DATA', 'IDX_ORDER_USER');
    DBMS_OUTPUT.PUT_LINE('IDX_ORDER_USER 推奨: ' || v_recommendation);
END;
/

-- 3. 個別インデックス最適化の例
DECLARE
    v_recommendation VARCHAR2(100);
    v_result VARCHAR2(4000);
BEGIN
    -- 特定のインデックスを分析して最適化
    v_recommendation := should_optimize_index('USER_DATA', 'IDX_USER_EMAIL');
    
    IF v_recommendation != 'MAINTAIN' THEN
        optimize_index('USER_DATA', 'IDX_USER_EMAIL', v_recommendation, v_result);
        DBMS_OUTPUT.PUT_LINE('最適化結果: ' || v_result);
    ELSE
        DBMS_OUTPUT.PUT_LINE('最適化は不要です');
    END IF;
END;
/

-- 4. バッチ最適化の手動実行
EXEC daily_index_optimization_batch;

-- 5. 最適化レポートの確認
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

-- 6. インデックス使用統計の確認
SELECT 
    table_name,
    index_name,
    COUNT(*) as usage_frequency,
    SUM(executions) as total_executions,
    AVG(elapsed_time) as avg_elapsed_time
FROM 
    index_usage_stats
WHERE 
    analysis_date >= SYSDATE - 7  -- 過去1週間
GROUP BY 
    table_name, index_name
ORDER BY 
    usage_frequency DESC;

-- 7. 最適化履歴の確認
SELECT 
    execution_date,
    table_name,
    index_name,
    optimization_type,
    status,
    execution_time,
    CASE 
        WHEN error_message IS NOT NULL THEN error_message
        ELSE 'SUCCESS'
    END as result
FROM 
    index_optimization_log
WHERE 
    execution_date >= SYSDATE - 30  -- 過去30日間
ORDER BY 
    execution_date DESC;