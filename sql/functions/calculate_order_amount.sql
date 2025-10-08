-- ================================================================
-- 注文金額を計算するファンクション
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE FUNCTION calculate_order_amount (
    p_product_id IN NUMBER,
    p_quantity   IN NUMBER
) RETURN NUMBER
IS
    v_price NUMBER(10,2);
    v_total_amount NUMBER(12,2);
BEGIN
    -- 商品価格を取得
    SELECT price
    INTO v_price
    FROM product_data
    WHERE product_id = p_product_id;
    
    -- 合計金額を計算
    v_total_amount := v_price * p_quantity;
    
    -- 割引適用ロジック (例: 10個以上で5%割引)
    IF p_quantity >= 10 THEN
        v_total_amount := v_total_amount * 0.95;
    END IF;
    
    RETURN v_total_amount;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1; -- 商品が見つからない場合
    WHEN OTHERS THEN
        RETURN -999; -- その他のエラー
END calculate_order_amount;
/