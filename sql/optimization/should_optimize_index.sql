-- ================================================================
-- インデックス最適化判定ファンクション
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE FUNCTION should_optimize_index(
    p_table_name IN VARCHAR2,
    p_index_name IN VARCHAR2
) RETURN VARCHAR2
IS
    v_clustering_factor NUMBER;
    v_num_rows NUMBER;
    v_blevel NUMBER;
    v_leaf_blocks NUMBER;
    v_usage_count NUMBER;
    v_avg_cost NUMBER;
    v_last_analyzed DATE;
    v_recommendation VARCHAR2(100);
BEGIN
    -- 現在の統計情報を取得
    SELECT 
        clustering_factor, num_rows, blevel, leaf_blocks, last_analyzed
    INTO 
        v_clustering_factor, v_num_rows, v_blevel, v_leaf_blocks, v_last_analyzed
    FROM user_indexes
    WHERE table_name = UPPER(p_table_name) AND index_name = UPPER(p_index_name);
    
    -- 使用頻度を取得
    SELECT COUNT(*)
    INTO v_usage_count
    FROM index_usage_stats
    WHERE table_name = UPPER(p_table_name) 
    AND index_name = UPPER(p_index_name)
    AND analysis_date >= SYSDATE - 30; -- 過去30日間
    
    -- 最適化判定ロジック
    IF v_last_analyzed IS NULL OR v_last_analyzed < SYSDATE - 7 THEN
        v_recommendation := 'ANALYZE';
    ELSIF v_usage_count = 0 THEN
        v_recommendation := 'DROP';
    ELSIF v_blevel >= 4 THEN
        v_recommendation := 'REBUILD';
    ELSIF v_clustering_factor > v_num_rows * 0.1 THEN
        v_recommendation := 'REBUILD';
    ELSIF v_leaf_blocks > 1000 AND v_usage_count < 10 THEN
        v_recommendation := 'COALESCE';
    ELSE
        v_recommendation := 'MAINTAIN';
    END IF;
    
    RETURN v_recommendation;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT_FOUND';
    WHEN OTHERS THEN
        RETURN 'ERROR';
END should_optimize_index;
/