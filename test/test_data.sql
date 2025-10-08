-- ================================================================
-- テストデータとパフォーマンステスト
-- @author RyuHazako
-- ================================================================

-- 初期設定データの投入
INSERT INTO index_optimization_config (config_id, table_name, optimization_rule, threshold_value, priority)
VALUES (index_config_seq.NEXTVAL, 'USER_DATA', 'CLUSTERING_FACTOR_RATIO', 0.1, 80);

INSERT INTO index_optimization_config (config_id, table_name, optimization_rule, threshold_value, priority)
VALUES (index_config_seq.NEXTVAL, 'PRODUCT_DATA', 'CLUSTERING_FACTOR_RATIO', 0.1, 70);

INSERT INTO index_optimization_config (config_id, table_name, optimization_rule, threshold_value, priority)
VALUES (index_config_seq.NEXTVAL, 'ORDER_DATA', 'CLUSTERING_FACTOR_RATIO', 0.1, 90);

INSERT INTO index_optimization_config (config_id, table_name, optimization_rule, threshold_value, priority)
VALUES (index_config_seq.NEXTVAL, 'SYSTEM_LOG', 'BLEVEL_THRESHOLD', 4, 60);

COMMIT;

-- パフォーマンステストケース
-- テストデータの大量挿入
DECLARE
    v_user_id NUMBER;
    v_product_id NUMBER;
    v_order_id NUMBER;
    v_result VARCHAR2(100);
BEGIN
    -- 大量ユーザーデータ挿入
    FOR i IN 1..1000 LOOP
        register_user('テストユーザー' || i, 'test' || i || '@example.com', v_user_id, v_result);
    END LOOP;
    
    -- 大量商品データ挿入
    FOR i IN 1..500 LOOP
        INSERT INTO product_data (product_id, product_name, price, category_id, stock_quantity)
        VALUES (product_id_seq.NEXTVAL, 'テスト商品' || i, i * 100, MOD(i, 10) + 1, i * 2);
    END LOOP;
    
    -- 大量注文データ挿入
    FOR i IN 1..5000 LOOP
        process_order(1000 + MOD(i, 1000), MOD(i, 500) + 1, MOD(i, 10) + 1, v_order_id, v_result);
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('パフォーマンステスト用データ挿入完了');
END;
/