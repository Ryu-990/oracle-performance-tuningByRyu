-- ================================================================
-- インデックス統計情報ビュー (レポート用)
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE VIEW v_index_optimization_report AS
SELECT 
    is.table_name,
    is.index_name,
    is.column_names,
    is.num_rows,
    is.distinct_keys,
    is.blevel,
    is.leaf_blocks,
    is.clustering_factor,
    is.selectivity,
    is.cost_estimate,
    is.last_analyzed,
    is.analysis_date,
    ius.usage_count,
    iol.optimization_type as last_optimization,
    iol.execution_date as last_optimization_date,
    CASE 
        WHEN is.last_analyzed IS NULL OR is.last_analyzed < SYSDATE - 7 THEN 'STALE_STATS'
        WHEN ius.usage_count = 0 THEN 'UNUSED'
        WHEN is.cost_estimate > 1000 THEN 'HIGH_COST'
        ELSE 'HEALTHY'
    END as health_status
FROM 
    index_statistics is
    LEFT JOIN (
        SELECT table_name, index_name, COUNT(*) as usage_count
        FROM index_usage_stats
        WHERE analysis_date >= SYSDATE - 30
        GROUP BY table_name, index_name
    ) ius ON is.table_name = ius.table_name AND is.index_name = ius.index_name
    LEFT JOIN (
        SELECT 
            table_name, index_name, optimization_type, execution_date,
            ROW_NUMBER() OVER (PARTITION BY table_name, index_name ORDER BY execution_date DESC) as rn
        FROM index_optimization_log
        WHERE status = 'SUCCESS'
    ) iol ON is.table_name = iol.table_name AND is.index_name = iol.index_name AND iol.rn = 1
WHERE 
    is.analysis_date = (
        SELECT MAX(analysis_date)
        FROM index_statistics is2
        WHERE is2.table_name = is.table_name AND is2.index_name = is.index_name
    );