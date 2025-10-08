-- ================================================================
-- インデックス使用状況収集プロシージャ
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE PROCEDURE collect_index_usage_stats
IS
    CURSOR c_sql_stats IS
        SELECT 
            p.object_name as table_name,
            p.object_name as index_name, -- この部分は実際のSQL計画から取得する必要があります
            s.sql_id,
            s.plan_hash_value,
            s.executions,
            s.rows_processed,
            s.elapsed_time,
            s.cpu_time,
            s.disk_reads,
            s.buffer_gets
        FROM 
            v$sql s,
            v$sql_plan p
        WHERE 
            s.sql_id = p.sql_id
            AND p.operation = 'INDEX'
            AND s.last_active_time >= SYSDATE - 1; -- 過去24時間のデータ
            
    v_usage_id NUMBER;
BEGIN
    FOR rec IN c_sql_stats LOOP
        -- 既存レコードの更新または新規挿入
        SELECT index_usage_seq.NEXTVAL INTO v_usage_id FROM DUAL;
        
        INSERT INTO index_usage_stats (
            usage_id, table_name, index_name, sql_id, plan_hash_value,
            executions, rows_processed, elapsed_time, cpu_time,
            disk_reads, buffer_gets
        ) VALUES (
            v_usage_id, rec.table_name, rec.index_name, rec.sql_id, rec.plan_hash_value,
            rec.executions, rec.rows_processed, rec.elapsed_time, rec.cpu_time,
            rec.disk_reads, rec.buffer_gets
        );
    END LOOP;
    
    COMMIT;
    
    -- ログ出力
    INSERT INTO system_log (log_id, log_level, log_message, function_name)
    VALUES (log_id_seq.NEXTVAL, 'INFO', 'インデックス使用統計収集完了', 'collect_index_usage_stats');
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO system_log (log_id, log_level, log_message, function_name)
        VALUES (log_id_seq.NEXTVAL, 'ERROR', 'インデックス使用統計収集エラー: ' || SQLERRM, 'collect_index_usage_stats');
        COMMIT;
END collect_index_usage_stats;
/