-- ================================================================
-- ユーザー名とカウントを結合するファンクション
-- @author RyuHazako
-- ================================================================

CREATE OR REPLACE FUNCTION your_function (
    p_name  IN VARCHAR2,
    p_count IN NUMBER
) RETURN VARCHAR2
IS
    v_result VARCHAR2(500);
BEGIN
    -- 入力パラメータの検証
    IF p_name IS NULL OR p_count IS NULL THEN
        RETURN 'エラー: パラメータが不正です';
    END IF;
    
    -- ビジネスロジック: 名前とカウントを組み合わせた文字列を生成
    IF p_count > 0 THEN
        v_result := p_name || 'さん (' || p_count || '回目の処理)';
    ELSE
        v_result := p_name || 'さん (初回処理)';
    END IF;
    
    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'エラー: ' || SQLERRM;
END your_function;
/