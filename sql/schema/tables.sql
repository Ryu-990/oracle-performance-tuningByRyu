-- ================================================================
-- テーブル定義 (データワーク)
-- @author RyuHazako
-- ================================================================

-- ユーザーデータテーブル
CREATE TABLE user_data (
    id          NUMBER(10) PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    email       VARCHAR2(200) UNIQUE NOT NULL,
    created_at  DATE DEFAULT SYSDATE,
    updated_at  DATE DEFAULT SYSDATE
);

-- 商品データテーブル (追加サンプル)
CREATE TABLE product_data (
    product_id      NUMBER(10) PRIMARY KEY,
    product_name    VARCHAR2(200) NOT NULL,
    price          NUMBER(10,2) NOT NULL,
    category_id    NUMBER(5),
    stock_quantity NUMBER(10) DEFAULT 0,
    created_at     DATE DEFAULT SYSDATE,
    updated_at     DATE DEFAULT SYSDATE
);

-- 注文データテーブル (関連テーブルサンプル)
CREATE TABLE order_data (
    order_id       NUMBER(12) PRIMARY KEY,
    user_id        NUMBER(10) NOT NULL,
    product_id     NUMBER(10) NOT NULL,
    quantity       NUMBER(5) NOT NULL,
    order_amount   NUMBER(12,2) NOT NULL,
    order_status   VARCHAR2(20) DEFAULT 'PENDING',
    order_date     DATE DEFAULT SYSDATE,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES user_data(id),
    CONSTRAINT fk_order_product FOREIGN KEY (product_id) REFERENCES product_data(product_id)
);

-- ログテーブル (ストアドプロシージャで使用)
CREATE TABLE system_log (
    log_id         NUMBER(15) PRIMARY KEY,
    log_level      VARCHAR2(10) NOT NULL,
    log_message    VARCHAR2(4000) NOT NULL,
    log_timestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id        NUMBER(10),
    function_name  VARCHAR2(100)
);

-- インデックス統計情報管理テーブル
CREATE TABLE index_statistics (
    stat_id          NUMBER(15) PRIMARY KEY,
    table_name       VARCHAR2(128) NOT NULL,
    index_name       VARCHAR2(128) NOT NULL,
    column_names     VARCHAR2(500) NOT NULL,
    num_rows         NUMBER,
    distinct_keys    NUMBER,
    blevel           NUMBER,
    leaf_blocks      NUMBER,
    clustering_factor NUMBER,
    avg_leaf_blocks_per_key NUMBER,
    avg_data_blocks_per_key NUMBER,
    selectivity      NUMBER(10,6),
    cost_estimate    NUMBER,
    last_analyzed    DATE,
    analysis_date    DATE DEFAULT SYSDATE,
    status           VARCHAR2(20) DEFAULT 'ACTIVE'
);

-- インデックス使用統計テーブル
CREATE TABLE index_usage_stats (
    usage_id         NUMBER(15) PRIMARY KEY,
    table_name       VARCHAR2(128) NOT NULL,
    index_name       VARCHAR2(128) NOT NULL,
    sql_id           VARCHAR2(13),
    plan_hash_value  NUMBER,
    executions       NUMBER DEFAULT 0,
    rows_processed   NUMBER DEFAULT 0,
    elapsed_time     NUMBER DEFAULT 0,
    cpu_time         NUMBER DEFAULT 0,
    disk_reads       NUMBER DEFAULT 0,
    buffer_gets      NUMBER DEFAULT 0,
    analysis_date    DATE DEFAULT SYSDATE,
    last_active      DATE DEFAULT SYSDATE
);

-- インデックス最適化履歴テーブル
CREATE TABLE index_optimization_log (
    log_id           NUMBER(15) PRIMARY KEY,
    table_name       VARCHAR2(128) NOT NULL,
    index_name       VARCHAR2(128),
    optimization_type VARCHAR2(50) NOT NULL, -- REBUILD, DROP, CREATE, COALESCE
    old_config       CLOB,
    new_config       CLOB,
    cost_before      NUMBER,
    cost_after       NUMBER,
    execution_time   NUMBER, -- 秒
    status           VARCHAR2(20) NOT NULL, -- SUCCESS, FAILED, PENDING
    error_message    VARCHAR2(4000),
    executed_by      VARCHAR2(100) DEFAULT USER,
    execution_date   DATE DEFAULT SYSDATE
);

-- インデックス最適化設定テーブル
CREATE TABLE index_optimization_config (
    config_id        NUMBER(10) PRIMARY KEY,
    table_name       VARCHAR2(128) NOT NULL,
    index_name       VARCHAR2(128),
    optimization_rule VARCHAR2(100) NOT NULL,
    threshold_value  NUMBER,
    is_enabled       CHAR(1) DEFAULT 'Y',
    priority         NUMBER(3) DEFAULT 50,
    created_date     DATE DEFAULT SYSDATE,
    updated_date     DATE DEFAULT SYSDATE
);