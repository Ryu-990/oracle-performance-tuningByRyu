-- ================================================================
-- ユーザー登録プロシージャ
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE PROCEDURE register_user (
    p_name    IN VARCHAR2,
    p_email   IN VARCHAR2,
    p_user_id OUT NUMBER,
    p_result  OUT VARCHAR2
)
IS
    v_count NUMBER;
BEGIN
    -- メールアドレスの重複チェック
    SELECT COUNT(*)
    INTO v_count
    FROM user_data
    WHERE email = p_email;
    
    IF v_count > 0 THEN
        p_result := 'エラー: メールアドレスが既に登録されています';
        p_user_id := -1;
        RETURN;
    END IF;
    
    -- 新しいユーザーIDを取得
    SELECT your_sequence.NEXTVAL INTO p_user_id FROM DUAL;
    
    -- ユーザーデータを挿入
    INSERT INTO user_data (id, name, email)
    VALUES (p_user_id, p_name, p_email);
    
    -- ログを記録
    INSERT INTO system_log (log_id, log_level, log_message, user_id, function_name)
    VALUES (log_id_seq.NEXTVAL, 'INFO', 'ユーザー登録完了: ' || p_name, p_user_id, 'register_user');
    
    COMMIT;
    p_result := '登録成功';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := 'エラー: ' || SQLERRM;
        p_user_id := -1;
END register_user;
/