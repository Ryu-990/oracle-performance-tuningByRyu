-- ================================================================
-- インデックス最適化実行プロシージャ
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE PROCEDURE optimize_index(
    p_table_name IN VARCHAR2,
    p_index_name IN VARCHAR2,
    p_optimization_type IN VARCHAR2,
    p_result OUT VARCHAR2
)
IS
    v_log_id NUMBER;
    v_start_time DATE;
    v_end_time DATE;
    v_execution_time NUMBER;
    v_cost_before NUMBER;
    v_cost_after NUMBER;
    v_old_config CLOB;
    v_new_config CLOB;
    v_sql_stmt VARCHAR2(4000);
BEGIN
    v_start_time := SYSDATE;
    
    -- ログIDを取得
    SELECT index_opt_log_seq.NEXTVAL INTO v_log_id FROM DUAL;
    
    -- 最適化前の設定を記録
    SELECT 'BLEVEL:' || blevel || ',LEAF_BLOCKS:' || leaf_blocks || ',CLUSTERING_FACTOR:' || clustering_factor
    INTO v_old_config
    FROM user_indexes
    WHERE table_name = UPPER(p_table_name) AND index_name = UPPER(p_index_name);
    
    -- 最適化タイプに応じた処理
    CASE p_optimization_type
        WHEN 'REBUILD' THEN
            v_sql_stmt := 'ALTER INDEX ' || p_index_name || ' REBUILD';
            EXECUTE IMMEDIATE v_sql_stmt;
            
        WHEN 'COALESCE' THEN
            v_sql_stmt := 'ALTER INDEX ' || p_index_name || ' COALESCE';
            EXECUTE IMMEDIATE v_sql_stmt;
            
        WHEN 'ANALYZE' THEN
            v_sql_stmt := 'ANALYZE INDEX ' || p_index_name || ' COMPUTE STATISTICS';
            EXECUTE IMMEDIATE v_sql_stmt;
            
        WHEN 'DROP' THEN
            v_sql_stmt := 'DROP INDEX ' || p_index_name;
            EXECUTE IMMEDIATE v_sql_stmt;
            
        ELSE
            p_result := 'INVALID_OPTIMIZATION_TYPE';
            RETURN;
    END CASE;
    
    v_end_time := SYSDATE;
    v_execution_time := (v_end_time - v_start_time) * 24 * 60 * 60; -- 秒
    
    -- 最適化後の設定を記録 (DROPの場合は除く)
    IF p_optimization_type != 'DROP' THEN
        SELECT 'BLEVEL:' || blevel || ',LEAF_BLOCKS:' || leaf_blocks || ',CLUSTERING_FACTOR:' || clustering_factor
        INTO v_new_config
        FROM user_indexes
        WHERE table_name = UPPER(p_table_name) AND index_name = UPPER(p_index_name);
    ELSE
        v_new_config := 'DROPPED';
    END IF;
    
    -- 最適化ログを記録
    INSERT INTO index_optimization_log (
        log_id, table_name, index_name, optimization_type,
        old_config, new_config, execution_time, status
    ) VALUES (
        v_log_id, UPPER(p_table_name), UPPER(p_index_name), p_optimization_type,
        v_old_config, v_new_config, v_execution_time, 'SUCCESS'
    );
    
    COMMIT;
    p_result := 'SUCCESS';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        -- エラーログを記録
        INSERT INTO index_optimization_log (
            log_id, table_name, index_name, optimization_type,
            old_config, execution_time, status, error_message
        ) VALUES (
            v_log_id, UPPER(p_table_name), UPPER(p_index_name), p_optimization_type,
            v_old_config, NVL(v_execution_time, 0), 'FAILED', SQLERRM
        );
        COMMIT;
        p_result := 'ERROR: ' || SQLERRM;
END optimize_index;
/