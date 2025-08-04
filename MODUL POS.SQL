-- ============================================
-- TABEL: products
-- Menyimpan data produk per tenant dan cabang
-- ============================================
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_id INT,
  name VARCHAR(100),
  category_id INT,
  stock INT DEFAULT 0,
  price DECIMAL(12,2),
  unit VARCHAR(20),
  foto_path VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- ============================================
-- TABEL: categories
-- Kategori produk per tenant
-- ============================================
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: penjualan
-- Header transaksi penjualan
-- ============================================
CREATE TABLE penjualan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_id INT,
  user_id INT,
  date DATE,
  total_amount DECIMAL(12,2),
  payment_method VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: penjualan_items
-- Detail item dalam transaksi penjualan
-- ============================================
CREATE TABLE penjualan_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  penjualan_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(12,2),
  discount DECIMAL(12,2) DEFAULT 0,
  FOREIGN KEY (penjualan_id) REFERENCES penjualan(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ============================================
-- TABEL: cash_transactions
-- Pencatatan kas masuk/keluar di luar penjualan
-- ============================================
CREATE TABLE cash_transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_id INT,
  user_id INT,
  type VARCHAR(20), -- "in" or "out"
  amount DECIMAL(12,2),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: employee_loans
-- Kasbon karyawan
-- ============================================
CREATE TABLE employee_loans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  user_id INT,
  amount DECIMAL(12,2),
  status VARCHAR(20) DEFAULT "unpaid",
  due_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: customer_loans
-- Kasbon pelanggan
-- ============================================
CREATE TABLE customer_loans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  customer_name VARCHAR(100),
  phone_number VARCHAR(20),
  amount DECIMAL(12,2),
  status VARCHAR(20) DEFAULT "unpaid",
  due_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: stock_notifications
-- Notifikasi stok rendah atau produk laris
-- ============================================
CREATE TABLE stock_notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  product_id INT,
  type VARCHAR(20), -- "low_stock" or "fast_selling"
  message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ============================================
-- TABEL: profit_loss_reports
-- Laporan laba rugi sederhana per cabang
-- ============================================
CREATE TABLE profit_loss_reports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_id INT,
  report_date DATE,
  total_income DECIMAL(12,2),
  total_expense DECIMAL(12,2),
  net_profit DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- ============================================
-- TABEL: expense_categories
-- Kategori pengeluaran
-- ============================================
CREATE TABLE expense_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: expenses
-- Pengeluaran operasional, promosi, dll
-- ============================================
CREATE TABLE expenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_id INT,
  category_id INT,
  amount DECIMAL(12,2),
  description TEXT,
  expense_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (category_id) REFERENCES expense_categories(id)
);

-- ============================================
-- TABEL: product_units
-- Menyimpan data unit dan harga per unit produk
-- ============================================
CREATE TABLE product_units (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  unit_name VARCHAR(50),
  unit_price DECIMAL(12,2),
  conversion_rate DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id)
);