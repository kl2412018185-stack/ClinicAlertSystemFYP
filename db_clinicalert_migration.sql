-- ==========================================================
-- Clinic Alert - schema migration for db_clinicalert Brings the phpMyAdmin dump (db_clinicalert.sql) in line with the columns the Java DAOs actually use.
--
-- Run ONCE against an existing db_clinicalert (MariaDB 10.4+ / MySQL 8 with IF NOT EXISTS support on ADD COLUMN; on plain MySQL 8 remove the "IF NOT EXISTS" clauses and run each statement only once).
-- ==========================================================

USE db_clinicalert;

-- ----------------------------------------------------------
-- 1. stock_out: columns used by TransactionDAO / MedicineDAO
-- ----------------------------------------------------------
ALTER TABLE stock_out
  ADD COLUMN IF NOT EXISTS medicine_id    INT          NULL AFTER stock_out_id,
  ADD COLUMN IF NOT EXISTS batch_no       VARCHAR(100) NULL AFTER item_id,
  ADD COLUMN IF NOT EXISTS quantity_out   INT          NULL AFTER quantity,
  ADD COLUMN IF NOT EXISTS reason         VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS stock_out_date DATE         NULL,
  ADD COLUMN IF NOT EXISTS remarks        VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS issued_by      INT          NULL;

UPDATE stock_out so
  JOIN medicines m ON m.item_id = so.item_id
   SET so.medicine_id    = COALESCE(so.medicine_id, m.medicine_id),
       so.quantity_out   = COALESCE(so.quantity_out, so.quantity),
       so.stock_out_date = COALESCE(so.stock_out_date, so.issued_date);

CREATE INDEX IF NOT EXISTS idx_stock_out_item_batch ON stock_out (item_id, batch_no);
CREATE INDEX IF NOT EXISTS idx_stock_in_item_batch  ON stock_in  (item_id, batch_no);

-- ----------------------------------------------------------
-- 2. restock_orders: columns used by RestockDAO
-- ----------------------------------------------------------
ALTER TABLE restock_orders
  ADD COLUMN IF NOT EXISTS order_no               VARCHAR(40)   NULL AFTER order_id,
  ADD COLUMN IF NOT EXISTS supplier_id            INT           NULL AFTER order_no,
  ADD COLUMN IF NOT EXISTS requested_by           INT           NULL AFTER supplier_id,
  ADD COLUMN IF NOT EXISTS expected_delivery_date DATE          NULL AFTER order_date,
  ADD COLUMN IF NOT EXISTS approved_by            INT           NULL,
  ADD COLUMN IF NOT EXISTS approved_at            DATETIME      NULL,
  ADD COLUMN IF NOT EXISTS approval_remarks       VARCHAR(500)  NULL,
  ADD COLUMN IF NOT EXISTS total_amount           DECIMAL(12,2) NOT NULL DEFAULT 0.00;

ALTER TABLE restock_orders MODIFY supplier VARCHAR(255) NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_restock_order_no ON restock_orders (order_no);

