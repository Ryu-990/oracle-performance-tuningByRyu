-- ================================================================
-- テストデータ投入用プロシージャ
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE PROCEDURE insert_test_data
IS
BEGIN
    -- 商品データの投入
    INSERT INTO product_data (product_id, product_name, price, category_id, stock_quantity)
    VALUES (product_id_seq.NEXTVAL, 'テスト商品A', 1000.00, 1, 50);
    
    INSERT INTO product_data (product_id, product_name, price, category_id, stock_quantity)
    VALUES (product_id_seq.NEXTVAL, 'テスト商品B', 2500.00, 2, 30);
    
    INSERT INTO product_data (product_id, product_name, price, category_id, stock_quantity)
    VALUES (product_id_seq.NEXTVAL, 'テスト商品C', 500.00, 1, 100);
    
    -- 初期ユーザーデータの投入
    INSERT INTO user_data (id, name, email)
    VALUES (your_sequence.NEXTVAL, 'テスト太郎', 'test.taro@example.com');
    
    INSERT INTO user_data (id, name, email)
    VALUES (your_sequence.NEXTVAL, 'テスト花子', 'test.hanako@example.com');
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('テストデータの投入が完了しました');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('テストデータ投入エラー: ' || SQLERRM);
END insert_test_data;
/