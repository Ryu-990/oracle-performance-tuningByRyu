-- ================================================================
-- 注文処理プロシージャ
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE PROCEDURE process_order (
    p_user_id    IN NUMBER,
    p_product_id IN NUMBER,
    p_quantity   IN NUMBER,
    p_order_id   OUT NUMBER,
    p_result     OUT VARCHAR2
)
IS
    v_user_count NUMBER;
    v_product_count NUMBER;
    v_stock_quantity NUMBER;
    v_order_amount NUMBER(12,2);
BEGIN
    -- ユーザー存在チェック
    SELECT COUNT(*)
    INTO v_user_count
    FROM user_data
    WHERE id = p_user_id;
    
    IF v_user_count = 0 THEN
        p_result := 'エラー: ユーザーが存在しません';
        p_order_id := -1;
        RETURN;
    END IF;
    
    -- 商品存在チェックと在庫確認
    SELECT COUNT(*), NVL(MAX(stock_quantity), 0)
    INTO v_product_count, v_stock_quantity
    FROM product_data
    WHERE product_id = p_product_id;
    
    IF v_product_count = 0 THEN
        p_result := 'エラー: 商品が存在しません';
        p_order_id := -1;
        RETURN;
    END IF;
    
    IF v_stock_quantity < p_quantity THEN
        p_result := 'エラー: 在庫不足です (在庫数: ' || v_stock_quantity || ')';
        p_order_id := -1;
        RETURN;
    END IF;
    
    -- 注文金額を計算
    v_order_amount := calculate_order_amount(p_product_id, p_quantity);
    
    IF v_order_amount < 0 THEN
        p_result := 'エラー: 金額計算に失敗しました';
        p_order_id := -1;
        RETURN;
    END IF;
    
    -- 注文IDを取得
    SELECT order_id_seq.NEXTVAL INTO p_order_id FROM DUAL;
    
    -- 注文データを挿入
    INSERT INTO order_data (order_id, user_id, product_id, quantity, order_amount)
    VALUES (p_order_id, p_user_id, p_product_id, p_quantity, v_order_amount);
    
    -- 在庫を更新
    UPDATE product_data
    SET stock_quantity = stock_quantity - p_quantity,
        updated_at = SYSDATE
    WHERE product_id = p_product_id;
    
    -- ログを記録
    INSERT INTO system_log (log_id, log_level, log_message, user_id, function_name)
    VALUES (log_id_seq.NEXTVAL, 'INFO', '注文処理完了 Order ID: ' || p_order_id, p_user_id, 'process_order');
    
    COMMIT;
    p_result := '注文処理成功';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := 'エラー: ' || SQLERRM;
        p_order_id := -1;
END process_order;
/