-- ============================================
-- TABEL: tenants
-- ============================================
CREATE TABLE tenants (
  tenant_code VARCHAR(20) PRIMARY KEY,
  tenant_name VARCHAR(100),
  owner_name VARCHAR(100),
  phone_number VARCHAR(20),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'active'
);

-- ============================================
-- TABEL: branches
-- ============================================
CREATE TABLE branches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_name VARCHAR(100),
  address TEXT,
  phone_number VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: users
-- ============================================
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_id INT,
  username VARCHAR(50),
  password_hash TEXT,
  role_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- ============================================
-- TABEL: plans
-- ============================================
CREATE TABLE plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  plan_code VARCHAR(20) UNIQUE NOT NULL,
  plan_name VARCHAR(100),
  price_monthly INT DEFAULT 0,
  price_yearly INT DEFAULT 0,
  is_trial BOOLEAN DEFAULT FALSE,
  is_lifetime BOOLEAN DEFAULT FALSE,
  max_devices INT DEFAULT 1,
  description TEXT
);

-- ============================================
-- TABEL: subscriptions
-- ============================================
CREATE TABLE subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  plan_code VARCHAR(20),
  start_date DATE,
  end_date DATE,
  is_trial BOOLEAN DEFAULT FALSE,
  is_lifetime BOOLEAN DEFAULT FALSE,
  max_devices INT DEFAULT 1,
  status VARCHAR(20) DEFAULT 'active',
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (plan_code) REFERENCES plans(plan_code)
);

-- ============================================
-- TABEL: billing_records
-- ============================================
CREATE TABLE billing_records (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  plan_code VARCHAR(20),
  invoice_date DATE,
  due_date DATE,
  amount INT,
  is_trial BOOLEAN DEFAULT FALSE,
  is_lifetime BOOLEAN DEFAULT FALSE,
  status VARCHAR(20) DEFAULT 'unpaid',
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (plan_code) REFERENCES plans(plan_code)
);

-- ============================================
-- TABEL: features
-- ============================================
CREATE TABLE features (
  id INT AUTO_INCREMENT PRIMARY KEY,
  feature_code VARCHAR(20) UNIQUE NOT NULL,
  feature_name VARCHAR(100),
  price_monthly INT DEFAULT 0,
  price_yearly INT DEFAULT 0,
  price_onetime INT DEFAULT NULL,
  description TEXT
);

-- ============================================
-- TABEL: tenant_features
-- ============================================
CREATE TABLE tenant_features (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  feature_code VARCHAR(20),
  activated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'active',
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (feature_code) REFERENCES features(feature_code)
);

-- ============================================
-- TABEL: tenant_settings
-- ============================================
CREATE TABLE tenant_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  setting_key VARCHAR(50),
  setting_value TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: branch_settings
-- ============================================
CREATE TABLE branch_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  branch_id INT,
  setting_key VARCHAR(50),
  setting_value TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- ============================================
-- TABEL: device_logs
-- ============================================
CREATE TABLE device_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  device_id VARCHAR(100),
  user_id INT,
  action VARCHAR(100),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: activity_logs
-- ============================================
CREATE TABLE activity_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  user_id INT,
  activity TEXT,
  module VARCHAR(50),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: notifications
-- ============================================
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  title VARCHAR(100),
  message TEXT,
  type VARCHAR(20),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: roles
-- ============================================
CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  role_name VARCHAR(50),
  description TEXT,
  is_default BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: permissions
-- ============================================
CREATE TABLE permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  permission_key VARCHAR(50),
  description TEXT
);

-- ============================================
-- TABEL: role_permissions
-- ============================================
CREATE TABLE role_permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT,
  permission_id INT,
  FOREIGN KEY (role_id) REFERENCES roles(id),
  FOREIGN KEY (permission_id) REFERENCES permissions(id)
);

-- ============================================
-- TABEL: vendor_admins
-- ============================================
CREATE TABLE vendor_admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50),
  password_hash TEXT,
  email VARCHAR(100),
  role VARCHAR(20) DEFAULT 'superadmin',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABEL: audit_vendor_actions
-- ============================================
CREATE TABLE audit_vendor_actions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admin_id INT,
  action TEXT,
  target_tenant_code VARCHAR(20),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES vendor_admins(id)
);

-- ============================================
-- TABEL: support_tickets
-- ============================================
CREATE TABLE support_tickets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  subject VARCHAR(100),
  message TEXT,
  status VARCHAR(20) DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- Plans
INSERT INTO plans (plan_code, plan_name, price_monthly, price_yearly, is_trial, is_lifetime, max_devices, description) VALUES
('trial', 'Trial 30 Hari', 0, 0, TRUE, FALSE, 1, 'Gratis selama 30 hari.'),
('basic', 'Basic', 25000, 250000, FALSE, FALSE, 1, 'Untuk usaha kecil.'),
('multi', 'Multi Device', 50000, 500000, FALSE, FALSE, 3, 'Untuk tim kecil.'),
('lifetime', 'Lifetime Access', 0, 0, FALSE, TRUE, 9999, 'Akses selamanya.');

-- Features
INSERT INTO features (feature_code, feature_name, price_monthly, price_yearly, price_onetime, description) VALUES
('inventory', 'Manajemen Stok', 10000, 100000, 100000, 'Kelola stok barang.'),
('reporting', 'Laporan Keuangan', 15000, 150000, 150000, 'Laporan penjualan.'),
('kasbon', 'Kasbon Pelanggan', 5000, 50000, 50000, 'Catat hutang pelanggan.');

-- Permissions
INSERT INTO permissions (permission_key, description) VALUES
('view_reports', 'Melihat laporan'),
('edit_products', 'Mengedit produk'),
('delete_transaction', 'Menghapus transaksi'),
('delete_product', 'Menghapus produk'),
('delete_user', 'Menghapus pengguna');

-- Tenants
INSERT INTO tenants VALUES
('081234567890', 'Toko Sukses', 'Budi Santoso', '081234567890', 'budi@tokosukses.com', DEFAULT, 'active'),
('089876543210', 'Toko Abadi', 'Siti Aminah', '089876543210', 'siti@abadi.com', DEFAULT, 'active');

-- Subscriptions
INSERT INTO subscriptions (tenant_code, plan_code, start_date, end_date, is_trial, is_lifetime, max_devices, status) VALUES
('081234567890', 'basic', '2025-01-01', '2025-12-31', FALSE, FALSE, 1, 'active'),
('089876543210', 'lifetime', '2025-08-01', NULL, FALSE, TRUE, 9999, 'active');

-- Billing Records
INSERT INTO billing_records (tenant_code, plan_code, invoice_date, due_date, amount, is_trial, is_lifetime, status) VALUES
('081234567890', 'basic', '2025-01-01', '2025-01-07', 250000, FALSE, FALSE, 'paid'),
('081234567890', 'basic', '2025-02-01', '2025-02-07', 250000, FALSE, FALSE, 'paid');