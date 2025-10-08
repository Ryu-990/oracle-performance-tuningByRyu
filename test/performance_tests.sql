-- ================================================================
-- パフォーマンステストケース
-- @author RyuHazako
-- ================================================================

-- インデックス効果検証用クエリ
-- 1. ユーザー検索テスト
SET TIMING ON
SET AUTOTRACE ON

-- インデックス使用前後の比較
SELECT COUNT(*) FROM user_data WHERE email LIKE 'test%@example.com';

-- 注文データの複合条件検索
SELECT 
    o.order_id,
    u.name,
    p.product_name,
    o.order_amount
FROM 
    order_data o
    JOIN user_data u ON o.user_id = u.id
    JOIN product_data p ON o.product_id = p.product_id
WHERE 
    o.order_date >= SYSDATE - 30
    AND o.order_status = 'PENDING'
    AND p.category_id = 1;

-- 統計情報の確認
SELECT 
    table_name,
    index_name,
    num_rows,
    distinct_keys,
    blevel,
    leaf_blocks,
    clustering_factor,
    last_analyzed
FROM 
    user_indexes
WHERE 
    table_name IN ('USER_DATA', 'PRODUCT_DATA', 'ORDER_DATA')
ORDER BY 
    table_name, index_name;

-- インデックス最適化実行テスト
DECLARE
    v_recommendation VARCHAR2(100);
    v_result VARCHAR2(4000);
BEGIN
    -- 各テーブルのインデックスを分析
    FOR rec IN (SELECT table_name, index_name FROM user_indexes 
                WHERE table_name IN ('USER_DATA', 'PRODUCT_DATA', 'ORDER_DATA')) LOOP
        
        v_recommendation := should_optimize_index(rec.table_name, rec.index_name);
        DBMS_OUTPUT.PUT_LINE(rec.table_name || '.' || rec.index_name || ' 推奨: ' || v_recommendation);
        
        IF v_recommendation = 'ANALYZE' THEN
            optimize_index(rec.table_name, rec.index_name, v_recommendation, v_result);
            DBMS_OUTPUT.PUT_LINE('最適化結果: ' || v_result);
        END IF;
    END LOOP;
END;
/

SET TIMING OFF
SET AUTOTRACE OFF