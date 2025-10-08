-- ================================================================
-- データクリーンアッププロシージャ (テスト用)
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE PROCEDURE cleanup_test_data
IS
BEGIN
    -- 外部キー制約順序でデータを削除
    DELETE FROM order_data;
    DELETE FROM system_log;
    DELETE FROM user_data;
    DELETE FROM product_data;
    
    -- シーケンスをリセット（テスト用）
    EXECUTE IMMEDIATE 'DROP SEQUENCE your_sequence';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE your_sequence START WITH 1000 INCREMENT BY 1 CACHE 20';
    
    EXECUTE IMMEDIATE 'DROP SEQUENCE product_id_seq';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE product_id_seq START WITH 1 INCREMENT BY 1 CACHE 10';
    
    EXECUTE IMMEDIATE 'DROP SEQUENCE order_id_seq';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE order_id_seq START WITH 100000 INCREMENT BY 1 CACHE 50';
    
    EXECUTE IMMEDIATE 'DROP SEQUENCE log_id_seq';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE log_id_seq START WITH 1 INCREMENT BY 1 CACHE 100';
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('テストデータのクリーンアップが完了しました');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('クリーンアップエラー: ' || SQLERRM);
END cleanup_test_data;
/