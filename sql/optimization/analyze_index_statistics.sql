-- ================================================================
-- インデックス統計情報収集ファンクション
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE FUNCTION analyze_index_statistics(
    p_table_name IN VARCHAR2,
    p_index_name IN VARCHAR2
) RETURN NUMBER
IS
    v_num_rows NUMBER;
    v_distinct_keys NUMBER;
    v_blevel NUMBER;
    v_leaf_blocks NUMBER;
    v_clustering_factor NUMBER;
    v_avg_leaf_blocks_per_key NUMBER;
    v_avg_data_blocks_per_key NUMBER;
    v_selectivity NUMBER;
    v_cost_estimate NUMBER;
    v_last_analyzed DATE;
    v_column_names VARCHAR2(500);
    v_stat_id NUMBER;
BEGIN
    -- インデックス統計情報を取得
    SELECT 
        i.num_rows,
        i.distinct_keys,
        i.blevel,
        i.leaf_blocks,
        i.clustering_factor,
        i.avg_leaf_blocks_per_key,
        i.avg_data_blocks_per_key,
        i.last_analyzed,
        LISTAGG(ic.column_name, ',') WITHIN GROUP (ORDER BY ic.column_position) AS column_names
    INTO 
        v_num_rows, v_distinct_keys, v_blevel, v_leaf_blocks, 
        v_clustering_factor, v_avg_leaf_blocks_per_key, 
        v_avg_data_blocks_per_key, v_last_analyzed, v_column_names
    FROM 
        user_indexes i
        JOIN user_ind_columns ic ON i.index_name = ic.index_name
    WHERE 
        i.table_name = UPPER(p_table_name)
        AND i.index_name = UPPER(p_index_name)
    GROUP BY 
        i.num_rows, i.distinct_keys, i.blevel, i.leaf_blocks,
        i.clustering_factor, i.avg_leaf_blocks_per_key,
        i.avg_data_blocks_per_key, i.last_analyzed;
    
    -- 選択性を計算
    v_selectivity := CASE WHEN v_num_rows > 0 THEN v_distinct_keys / v_num_rows ELSE 0 END;
    
    -- コスト推定値を計算 (簡単な近似式)
    v_cost_estimate := v_blevel + CEIL(v_leaf_blocks * v_selectivity) + 
                      CEIL(v_num_rows * v_selectivity / NVL(v_clustering_factor, 1));
    
    -- 統計情報をテーブルに保存
    SELECT index_stat_seq.NEXTVAL INTO v_stat_id FROM DUAL;
    
    INSERT INTO index_statistics (
        stat_id, table_name, index_name, column_names,
        num_rows, distinct_keys, blevel, leaf_blocks,
        clustering_factor, avg_leaf_blocks_per_key, avg_data_blocks_per_key,
        selectivity, cost_estimate, last_analyzed
    ) VALUES (
        v_stat_id, UPPER(p_table_name), UPPER(p_index_name), v_column_names,
        v_num_rows, v_distinct_keys, v_blevel, v_leaf_blocks,
        v_clustering_factor, v_avg_leaf_blocks_per_key, v_avg_data_blocks_per_key,
        v_selectivity, v_cost_estimate, v_last_analyzed
    );
    
    RETURN v_stat_id;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
    WHEN OTHERS THEN
        RETURN -999;
END analyze_index_statistics;
/