-- ================================================================
-- インデックス作成 (パフォーマンス向上)
-- @author RyuHazako
-- ================================================================

CREATE INDEX idx_user_email ON user_data(email);
CREATE INDEX idx_product_category ON product_data(category_id);
CREATE INDEX idx_order_user ON order_data(user_id);
CREATE INDEX idx_order_product ON order_data(product_id);
CREATE INDEX idx_order_date ON order_data(order_date);
CREATE INDEX idx_log_timestamp ON system_log(log_timestamp);
CREATE INDEX idx_log_user ON system_log(user_id);