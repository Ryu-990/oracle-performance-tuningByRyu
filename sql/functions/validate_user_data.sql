-- ================================================================
-- ユーザー情報を検証するファンクション
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE FUNCTION validate_user_data (
    p_user_id IN NUMBER,
    p_email   IN VARCHAR2
) RETURN VARCHAR2
IS
    v_count NUMBER;
    v_result VARCHAR2(100);
BEGIN
    -- ユーザーIDの存在チェック
    SELECT COUNT(*)
    INTO v_count
    FROM user_data
    WHERE id = p_user_id;
    
    IF v_count = 0 THEN
        RETURN 'ユーザーが存在しません';
    END IF;
    
    -- メールアドレスの重複チェック (自分以外)
    SELECT COUNT(*)
    INTO v_count
    FROM user_data
    WHERE email = p_email AND id != p_user_id;
    
    IF v_count > 0 THEN
        RETURN 'メールアドレスが重複しています';
    END IF;
    
    RETURN '検証OK';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'エラー: ' || SQLERRM;
END validate_user_data;
/