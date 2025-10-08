-- ================================================================
-- シーケンス定義 (ヘッダワーク)
-- @author RyuHazako
-- ================================================================

-- ユーザーIDシーケンス
CREATE SEQUENCE your_sequence
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    CACHE 20;

-- 商品IDシーケンス
CREATE SEQUENCE product_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999
    NOCYCLE
    CACHE 10;

-- 注文IDシーケンス
CREATE SEQUENCE order_id_seq
    START WITH 100000
    INCREMENT BY 1
    MINVALUE 100000
    MAXVALUE 999999999999
    NOCYCLE
    CACHE 50;

-- ログIDシーケンス
CREATE SEQUENCE log_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999999
    NOCYCLE
    CACHE 100;

-- インデックス最適化関連シーケンス
CREATE SEQUENCE index_stat_seq START WITH 1 INCREMENT BY 1 CACHE 100;
CREATE SEQUENCE index_usage_seq START WITH 1 INCREMENT BY 1 CACHE 100;
CREATE SEQUENCE index_opt_log_seq START WITH 1 INCREMENT BY 1 CACHE 50;
CREATE SEQUENCE index_config_seq START WITH 1 INCREMENT BY 1 CACHE 10;