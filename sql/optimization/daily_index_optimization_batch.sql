-- ================================================================
-- 日次インデックス最適化バッチプロシージャ
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE PROCEDURE daily_index_optimization_batch
IS
    CURSOR c_indexes IS
        SELECT 
            i.table_name,
            i.index_name,
            should_optimize_index(i.table_name, i.index_name) as recommendation
        FROM 
            user_indexes i
        WHERE 
            i.table_name IN ('USER_DATA', 'PRODUCT_DATA', 'ORDER_DATA', 'SYSTEM_LOG')
        ORDER BY 
            i.table_name, i.index_name;
    
    v_start_time DATE;
    v_end_time DATE;
    v_processed_count NUMBER := 0;
    v_optimized_count NUMBER := 0;
    v_result VARCHAR2(4000);
BEGIN
    v_start_time := SYSDATE;
    
    -- バッチ開始ログ
    INSERT INTO system_log (log_id, log_level, log_message, function_name)
    VALUES (log_id_seq.NEXTVAL, 'INFO', '日次インデックス最適化バッチ開始', 'daily_index_optimization_batch');
    
    -- 各インデックスをチェックして最適化
    FOR rec IN c_indexes LOOP
        v_processed_count := v_processed_count + 1;
        
        IF rec.recommendation NOT IN ('MAINTAIN', 'NOT_FOUND', 'ERROR') THEN
            optimize_index(rec.table_name, rec.index_name, rec.recommendation, v_result);
            
            IF v_result = 'SUCCESS' THEN
                v_optimized_count := v_optimized_count + 1;
            END IF;
            
            -- 個別最適化ログ
            INSERT INTO system_log (log_id, log_level, log_message, function_name)
            VALUES (log_id_seq.NEXTVAL, 'INFO', 
                   'インデックス最適化: ' || rec.table_name || '.' || rec.index_name || 
                   ' 推奨: ' || rec.recommendation || ' 結果: ' || v_result,
                   'daily_index_optimization_batch');
        END IF;
    END LOOP;
    
    v_end_time := SYSDATE;
    
    -- バッチ完了ログ
    INSERT INTO system_log (log_id, log_level, log_message, function_name)
    VALUES (log_id_seq.NEXTVAL, 'INFO', 
           '日次インデックス最適化バッチ完了 - 処理件数: ' || v_processed_count || 
           ', 最適化件数: ' || v_optimized_count || 
           ', 実行時間: ' || ROUND((v_end_time - v_start_time) * 24 * 60, 2) || '分',
           'daily_index_optimization_batch');
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO system_log (log_id, log_level, log_message, function_name)
        VALUES (log_id_seq.NEXTVAL, 'ERROR', 
               '日次インデックス最適化バッチエラー: ' || SQLERRM,
               'daily_index_optimization_batch');
        COMMIT;
END daily_index_optimization_batch;
/