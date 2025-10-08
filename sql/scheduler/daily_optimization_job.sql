-- ================================================================
-- Oracle Schedulerジョブの作成
-- @author RyuHazako
-- ================================================================

BEGIN
    -- 既存ジョブが存在する場合は削除
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(job_name => 'DAILY_INDEX_OPTIMIZATION_JOB');
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- ジョブが存在しない場合は無視
    END;
    
    -- 日次インデックス最適化ジョブを作成
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'DAILY_INDEX_OPTIMIZATION_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN daily_index_optimization_batch; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => '日次インデックス最適化バッチジョブ - 毎日午前2時に実行'
    );
    
    DBMS_OUTPUT.PUT_LINE('日次インデックス最適化ジョブが作成されました');
END;
/