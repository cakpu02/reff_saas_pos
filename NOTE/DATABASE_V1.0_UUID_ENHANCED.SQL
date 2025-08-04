-- ============================================
-- TABEL: tenants informasi tenant
-- ============================================
CREATE TABLE tenants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(100) NOT NULL UNIQUE, -- Kode unik untuk tenant (misal: 081234567890, TNT001 ATAU EMAIL)
  tenant_name VARCHAR(100), -- Nama tenant ATAU usaha
  owner_name VARCHAR(100),-- Nama pemilik tenant
  email VARCHAR(100) UNIQUE, -- Email tenant untuk notifikasi
  phone_number VARCHAR(20),
  alamat TEXT,  -- Alamat tenant
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Waktu pembuatan tenant
  status ENUM('active','inactive', 'suspended') NOT NULL DEFAULT 'active' -- Status tenant (active, inactive, suspended)
);
-- ============================================
-- TABEL: tenant_settings modular
-- Menyimpan pengaturan tenant seperti path_logo, nilai default, tema, dll
-- Pengaturan ini bisa diubah oleh vendor atau admin tenant
-- ============================================
CREATE TABLE tenant_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),-- Kode tenant untuk referensi
  setting_key VARCHAR(50),-- Kunci pengaturan (misal: "path_logo", "default_currency")
  setting_value TEXT,-- Nilai pengaturan (misal: "/images/logo.png", "IDR")
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: plans
-- Menyimpan data paket langganan dan harga di isi oleh vendor
-- ============================================
CREATE TABLE plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  plan_code VARCHAR(20) UNIQUE NOT NULL,-- Kode unik untuk paket (misal: 'trial', 'basic', 'multi', 'lifetime')
  plan_name VARCHAR(100),-- Nama paket (misal: 'Trial 30 Hari', 'Basic', 'Multi Device', 'Lifetime Access')
  price_monthly INT DEFAULT 0,-- Harga per bulan
  price_yearly INT DEFAULT 0,-- Harga per tahun
  is_trial BOOLEAN DEFAULT FALSE,-- Apakah paket ini trial
  is_lifetime BOOLEAN DEFAULT FALSE,-- Apakah paket ini lifetime
  max_devices INT DEFAULT 1,-- maksimal perangkat yang bisa digunakan
  description TEXT
);

-- ============================================
-- TABEL: subscriptions
-- Menyimpan data langganan tenant ke paket tertentu, saat daftar otomatis membuat data ini, diawal dapat trial
-- ============================================
CREATE TABLE subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  plan_code VARCHAR(20),-- Kode paket langganan 
  start_date DATE,-- Tanggal mulai langganan
  end_date DATE,-- Tanggal akhir langganan, NULL jika paket lifetime
  is_trial BOOLEAN DEFAULT FALSE,
  is_lifetime BOOLEAN DEFAULT FALSE,
  max_devices INT DEFAULT 1,-- Jumlah perangkat yang diizinkan
  status ENUM('active', 'expired', 'cancelled') NOT NULL DEFAULT 'active',-- Status langganan (active, expired, cancelled)
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (plan_code) REFERENCES plans(plan_code)
);
-- ============================================
-- TABEL: devices
-- Menyimpan data perangkat yang digunakan oleh tenant, seperti komputer, tablet, atau smartphone 
-- terkait dengan max_devices pada paket langganan
-- setiap perangkat memiliki ID unik (misal: UUID) untuk menghindari duplikasi dan memastikan keamanan
-- dapat digantikan jika perangkat hilang atau rusak
-- pertama kali login tenant akan otomatis membuat data perangkat ini
CREATE TABLE devices (
  id SERIAL PRIMARY KEY,
  tenant_code VARCHAR(20),
  device_id VARCHAR(100), -- UUID unik dari perangkat
  device_name VARCHAR(100),-- Nama perangkat (misal: "Laptop Budi", "Tablet Siti")
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ============================================
-- TABEL: features
-- Menyimpan fitur add-on yang tersedia untuk tenant, dengan harga per bulan, tahunan, atau sekali bayar
-- ============================================
CREATE TABLE features (
  id INT AUTO_INCREMENT PRIMARY KEY,
  feature_code VARCHAR(20) UNIQUE NOT NULL,-- Kode unik untuk fitur (misal: 'inventory', 'reporting', 'kasbon')
  feature_name VARCHAR(100),-- Nama fitur (misal: 'Manajemen Stok', 'Laporan Keuangan', 'Kasbon Pelanggan')
  price_monthly INT DEFAULT 0,
  price_yearly INT DEFAULT 0,
  price_onetime INT DEFAULT NULL,-- Harga sekali bayar jika ada
  description TEXT
);

-- ============================================
-- TABEL: tenant_features 
-- Menyimpan fitur add-on yang diaktifkan untuk tenant tertentu
-- masa berlaku fitur ini tergantung pada paket langganan yang diambil tenant, jika paket berakhir maka fitur ini juga berakhir
-- ============================================
CREATE TABLE tenant_features (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  feature_code VARCHAR(20),
  activated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',-- Status fitur (active, inactive)
   FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (feature_code) REFERENCES features(feature_code)
);

-- ============================================
-- TABEL: billing_records
-- Menyimpan data tagihan untuk tenant, mencatat tanggal tagihan, jatuh tempo, jumlah, dan status pembayaran
-- berisi data tagihan untuk paket langganan dan fitur add-on
-- ============================================
CREATE TABLE billing_records (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  plan_code VARCHAR(20),-- Kode paket langganan
  invoice_date DATE,-- Tanggal tagihan
  due_date DATE,-- Tanggal jatuh tempo
  amount INT,-- Jumlah tagihan
  is_trial BOOLEAN DEFAULT FALSE,-- Apakah ini tagihan untuk masa trial
  is_lifetime BOOLEAN DEFAULT FALSE,-- Apakah ini tagihan untuk paket lifetime
  status ENUM('unpaid', 'paid', 'overdue') NOT NULL DEFAULT 'unpaid',-- Status pembayaran (unpaid, paid, overdue  )
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (plan_code) REFERENCES plans(plan_code)
);


-- ============================================
-- TABEL: branches 
-- Menyimpan data cabang untuk tenant, jika ada
-- setiap tenant bisa memiliki beberapa cabang, cabang ini bisa digunakan untuk mengelompokkan data produk, penjualan, dan pengguna
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
-- TABEL: branch_settings jika ada cabang
-- Menyimpan pengaturan cabang seperti jam buka, lokasi,printer dll
-- ============================================
CREATE TABLE branch_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  branch_id INT,
  setting_key VARCHAR(50), -- Kunci pengaturan (misal: "opening_hours", "location")
  setting_value TEXT, -- Nilai pengaturan (misal: "08:00-17:00", "Jl. Raya No. 123")
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- ============================================
-- TABEL: users
-- Menyimpan data pengguna yang memiliki akses ke sistem, bisa berupa admin, kasir, manajer, dll
-- setiap pengguna terhubung ke tenant dan cabang tertentu
-- pengguna ini bisa memiliki peran yang berbeda-beda, tergantung pada hak akses yang diberikan
-- saat ini pengguna hanya bisa dibuat oleh vendor atau admin/owner tenant
-- pertama tenant mendaftar,sistem akan membuat pengguna default dengan role owner
-- ============================================
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),-- Kode tenant untuk referensi
  branch_id INT,--  ID cabang tempat pengguna berada
  username VARCHAR(50),-- Nama pengguna untuk login
  password_hash TEXT,
  role_id INT,-- ID peran pengguna (misal: admin, kasir, manajer)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (role_id) REFERENCES roles(id)
);


-- ============================================
-- TABEL: device_logs
-- Menyimpan log aktivitas perangkat yang digunakan oleh tenant
-- mencatat ID perangkat, pengguna yang mengakses, dan tindakan yang dilakukan
-- ============================================
CREATE TABLE device_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  device_id VARCHAR(100),-- ID unik perangkat (misal: UUID)
  user_id INT,
  action VARCHAR(100), --
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: activity_logs
-- Menyimpan log aktivitas pengguna di sistem, seperti penambahan produk, pengeditan transaksi, dll
-- setiap log terkait dengan tenant dan pengguna yang melakukan aktivitas tersebut
-- ============================================
CREATE TABLE activity_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  user_id INT,
  activity TEXT,-- Deskripsi aktivitas yang dilakukan (misal: "Menambahkan produk baru", "Mengedit transaksi penjualan")
  module VARCHAR(50),-- Modul sistem tempat aktivitas dilakukan (misal: "Inventory", "Sales")
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: notifications
-- Menyimpan notifikasi untuk tenant, seperti pemberitahuan sistem, peringatan stok rendah, dll
-- setiap notifikasi terkait dengan tenant tertentu
-- ============================================
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  title VARCHAR(100),-- Judul notifikasi
  message TEXT,
  type VARCHAR(20),
  is_read BOOLEAN DEFAULT FALSE,-- Status notifikasi (apakah sudah dibaca atau belum)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: roles
-- Menyimpan peran yang tersedia di sistem, seperti admin, kasir, manajer, dll
-- setiap peran memiliki hak akses tertentu yang bisa diberikan kepada pengguna
-- ============================================
CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  role_name VARCHAR(50),-- Nama peran (misal: "Admin", "Kasir", "Manajer")
  description TEXT,-- Deskripsi peran
  is_default BOOLEAN DEFAULT FALSE,-- Apakah peran ini adalah peran default untuk tenant
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- ============================================
-- TABEL: permissions
-- Menyimpan hak akses yang tersedia di sistem, seperti melihat laporan, mengedit produk, dll
-- setiap hak akses bisa diberikan kepada peran tertentu melalui tabel role_permissions
-- ============================================
CREATE TABLE permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  permission_key VARCHAR(50),-- Kunci unik untuk hak akses (misal: 'view_reports', 'edit_products', 'delete_transaction')
  description TEXT-- Deskripsi hak akses (misal: 'Melihat laporan', 'Mengedit produk', 'Menghapus transaksi')
);

-- ============================================
-- TABEL: role_permissions
-- Menyimpan hubungan antara peran dan hak akses yang dimiliki
-- setiap peran bisa memiliki beberapa hak akses, dan setiap hak akses bisa dimiliki oleh beberapa peran
-- ============================================
CREATE TABLE role_permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT,
  permission_id INT,
  FOREIGN KEY (role_id) REFERENCES roles(id),
  FOREIGN KEY (permission_id) REFERENCES permissions(id)
);

-- ============================================
-- TABEL: vendor_admins sebagai admin vendor pengelola sistem
-- Menyimpan data admin vendor yang mengelola sistem, seperti vendor utama atau superadmin
-- setiap admin vendor memiliki username, password hash, email, dan peran tertentu
-- ============================================
CREATE TABLE vendor_admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash TEXT,
  email VARCHAR(100),
  role VARCHAR(20) DEFAULT 'superadmin',-- Peran admin vendor (misal: 'superadmin', 'admin')
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABEL: audit_vendor_actions
-- Menyimpan log aktivitas admin vendor, seperti penambahan tenant, pengaturan sistem, dll
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
-- Menyimpan tiket dukungan yang dibuat oleh tenant untuk bantuan teknis atau pertanyaan
-- setiap tiket terkait dengan tenant tertentu dan memiliki status (open, closed, pending)
-- ============================================
CREATE TABLE support_tickets (
  id INT AUTO_INCREMENT PRIMARY KEY,  
  tenant_code VARCHAR(20),
  subject VARCHAR(100),
  message TEXT,
  status ENUM('open','closed', 'pending') NOT NULL DEFAULT 'open', -- Status tiket (open, closed, pending)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- POS Sistem
-- ============================================
-- TABEL: products
-- Menyimpan data produk per tenant dan cabang
-- ============================================
CREATE TABLE products (
  uuid VARCHAR(36) NOT NULL UNIQUE,
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),-- Kode tenant untuk referensi
  branch_id INT,--  ID cabang tempat produk tersedia
  name VARCHAR(100),
  category_id INT,
  stock INT DEFAULT 0,-- Jumlah stok produk
  price DECIMAL(12,2),
  unit VARCHAR(20),
  foto_path VARCHAR(255),-- Path foto produk
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id)
);
-- ============================================
-- TABEL: product_units
-- Menyimpan data unit dan harga per unit produk
-- ============================================
CREATE TABLE product_units (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  unit_name VARCHAR(50),-- Nama unit (misal: 'pcs', 'kg', 'liter')
  unit_price DECIMAL(12,2),-- Harga per unit
  conversion_rate DECIMAL(12,2),-- Rasio konversi ke unit dasar (misal: 1 kg = 1000 gram)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id)
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
-- setiap transaksi penjualan terkait dengan tenant, cabang, dan pengguna yang melakukan penjualan
-- transaksi ini mencatat total penjualan, metode pembayaran, dan waktu transaksi
-- ============================================
CREATE TABLE penjualan (
  uuid VARCHAR(36) NOT NULL UNIQUE,
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  branch_id INT,
  user_id INT,--- ID pengguna yang melakukan penjualan
  date DATE,
  total_amount DECIMAL(12,2),
  payment_method VARCHAR(50),-- Metode pembayaran (misal: 'cash', 'credit_card', 'transfer')
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
  uuid VARCHAR(36) NOT NULL UNIQUE,
  uuid_penjualan VARCHAR(36),
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
  uuid VARCHAR(36) NOT NULL UNIQUE,
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
  uuid VARCHAR(36) NOT NULL UNIQUE,
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  user_id INT,
  amount DECIMAL(12,2),
  status ENUM('unpaid', 'paid', 'overdue') NOT NULL DEFAULT 'unpaid',-- Status kasbon (unpaid, paid, overdue)
  due_date DATE,-- Tanggal jatuh tempo kasbon
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ============================================
-- TABEL: customer_loans
-- Kasbon pelanggan
-- Menyimpan data kasbon pelanggan, seperti nama, nomor telepon, jumlah, status, dan tanggal jatuh tempo
-- setiap kasbon terkait dengan tenant tertentu 
-- ============================================
CREATE TABLE customer_loans (
  uuid VARCHAR(36) NOT NULL UNIQUE,
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),  
  customer_name VARCHAR(100),
  phone_number VARCHAR(20),
  amount DECIMAL(12,2),
  status ENUM('unpaid', 'paid', 'overdue') NOT NULL DEFAULT 'unpaid',-- Status kasbon (unpaid, paid, overdue)
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
  name VARCHAR(100),-- Nama kategori pengeluaran (misal: "Operasional", "Promosi", "Gaji")
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
  category_id INT,-- ID kategori pengeluaran
  amount DECIMAL(12,2),-- Jumlah pengeluaran
  description TEXT,-- 
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,-- Tanggal pengeluaran
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (branch_id) REFERENCES branches(id),
  FOREIGN KEY (category_id) REFERENCES expense_categories(id)
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


-- =========================
-- INDEX OPTIMIZATION
-- =========================

-- Tenants
CREATE INDEX idx_tenants_tenant_code ON tenants(tenant_code); -- Mempercepat pencarian tenant berdasarkan kode tenant

-- Tenant Settings
CREATE INDEX idx_tenant_settings_tenant_code ON tenant_settings(tenant_code); -- Mempercepat filter pengaturan per tenant

-- Subscriptions
CREATE INDEX idx_subscriptions_tenant_code ON subscriptions(tenant_code); -- Mempercepat pencarian langganan per tenant
CREATE INDEX idx_subscriptions_plan_code ON subscriptions(plan_code); -- Mempercepat pencarian langganan per paket

-- Devices
CREATE INDEX idx_devices_tenant_code ON devices(tenant_code); -- Mempercepat pencarian perangkat per tenant
CREATE INDEX idx_devices_device_id ON devices(device_id); -- Mempercepat pencarian perangkat berdasarkan device_id

-- Tenant Features
CREATE INDEX idx_tenant_features_tenant_code ON tenant_features(tenant_code); -- Mempercepat pencarian fitur per tenant
CREATE INDEX idx_tenant_features_feature_code ON tenant_features(feature_code); -- Mempercepat pencarian fitur berdasarkan kode fitur

-- Billing Records
CREATE INDEX idx_billing_records_tenant_code ON billing_records(tenant_code); -- Mempercepat pencarian tagihan per tenant
CREATE INDEX idx_billing_records_plan_code ON billing_records(plan_code); -- Mempercepat pencarian tagihan per paket

-- Branches
CREATE INDEX idx_branches_tenant_code ON branches(tenant_code); -- Mempercepat pencarian cabang per tenant

-- Branch Settings
CREATE INDEX idx_branch_settings_branch_id ON branch_settings(branch_id); -- Mempercepat pencarian pengaturan per cabang

-- Users
CREATE INDEX idx_users_tenant_code ON users(tenant_code); -- Mempercepat pencarian user per tenant
CREATE INDEX idx_users_branch_id ON users(branch_id); -- Mempercepat pencarian user per cabang
CREATE INDEX idx_users_role_id ON users(role_id); -- Mempercepat pencarian user per role

-- Device Logs
CREATE INDEX idx_device_logs_tenant_code ON device_logs(tenant_code); -- Mempercepat pencarian log perangkat per tenant
CREATE INDEX idx_device_logs_user_id ON device_logs(user_id); -- Mempercepat pencarian log perangkat per user

-- Activity Logs
CREATE INDEX idx_activity_logs_tenant_code ON activity_logs(tenant_code); -- Mempercepat pencarian log aktivitas per tenant
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id); -- Mempercepat pencarian log aktivitas per user

-- Notifications
CREATE INDEX idx_notifications_tenant_code ON notifications(tenant_code); -- Mempercepat pencarian notifikasi per tenant

-- Roles
CREATE INDEX idx_roles_tenant_code ON roles(tenant_code); -- Mempercepat pencarian role per tenant

-- Role Permissions
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id); -- Mempercepat pencarian hak akses per role
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id); -- Mempercepat pencarian role berdasarkan permission

-- Audit Vendor Actions
CREATE INDEX idx_audit_vendor_actions_admin_id ON audit_vendor_actions(admin_id); -- Mempercepat pencarian log aksi admin vendor

-- Support Tickets
CREATE INDEX idx_support_tickets_tenant_code ON support_tickets(tenant_code); -- Mempercepat pencarian tiket dukungan per tenant

-- Products
CREATE INDEX idx_products_tenant_code ON products(tenant_code); -- Mempercepat pencarian produk per tenant
CREATE INDEX idx_products_branch_id ON products(branch_id); -- Mempercepat pencarian produk per cabang
CREATE INDEX idx_products_category_id ON products(category_id); -- Mempercepat pencarian produk per kategori

-- Product Units
CREATE INDEX idx_product_units_product_id ON product_units(product_id); -- Mempercepat pencarian unit produk per produk

-- Categories
CREATE INDEX idx_categories_tenant_code ON categories(tenant_code); -- Mempercepat pencarian kategori per tenant

-- Penjualan
CREATE INDEX idx_penjualan_tenant_code ON penjualan(tenant_code); -- Mempercepat pencarian penjualan per tenant
CREATE INDEX idx_penjualan_branch_id ON penjualan(branch_id); -- Mempercepat pencarian penjualan per cabang
CREATE INDEX idx_penjualan_user_id ON penjualan(user_id); -- Mempercepat pencarian penjualan per user

-- Penjualan Items
CREATE INDEX idx_penjualan_items_penjualan_id ON penjualan_items(penjualan_id); -- Mempercepat pencarian item penjualan per transaksi
CREATE INDEX idx_penjualan_items_product_id ON penjualan_items(product_id); -- Mempercepat pencarian item penjualan per produk

-- Cash Transactions
CREATE INDEX idx_cash_transactions_tenant_code ON cash_transactions(tenant_code); -- Mempercepat pencarian transaksi kas per tenant
CREATE INDEX idx_cash_transactions_branch_id ON cash_transactions(branch_id); -- Mempercepat pencarian transaksi kas per cabang
CREATE INDEX idx_cash_transactions_user_id ON cash_transactions(user_id); -- Mempercepat pencarian transaksi kas per user

-- Employee Loans
CREATE INDEX idx_employee_loans_tenant_code ON employee_loans(tenant_code); -- Mempercepat pencarian kasbon karyawan per tenant
CREATE INDEX idx_employee_loans_user_id ON employee_loans(user_id); -- Mempercepat pencarian kasbon karyawan per user

-- Customer Loans
CREATE INDEX idx_customer_loans_tenant_code ON customer_loans(tenant_code); -- Mempercepat pencarian kasbon pelanggan per tenant

-- Stock Notifications
CREATE INDEX idx_stock_notifications_tenant_code ON stock_notifications(tenant_code); -- Mempercepat pencarian notifikasi stok per tenant
CREATE INDEX idx_stock_notifications_product_id ON stock_notifications(product_id); -- Mempercepat pencarian notifikasi stok per produk

-- Profit Loss Reports
CREATE INDEX idx_profit_loss_reports_tenant_code ON profit_loss_reports(tenant_code); -- Mempercepat pencarian laporan laba rugi per tenant
CREATE INDEX idx_profit_loss_reports_branch_id ON profit_loss_reports(branch_id); -- Mempercepat pencarian laporan laba rugi per cabang

-- Expense Categories
CREATE INDEX idx_expense_categories_tenant_code ON expense_categories(tenant_code); -- Mempercepat pencarian kategori pengeluaran per tenant

-- Expenses
CREATE INDEX idx_expenses_tenant_code ON expenses(tenant_code); -- Mempercepat pencarian pengeluaran per tenant
CREATE INDEX idx_expenses_branch_id ON expenses(branch_id); -- Mempercepat pencarian pengeluaran per cabang
CREATE INDEX idx_expenses_category_id ON expenses(category_id); -- Mempercepat pencarian pengeluaran per kategori

-- =========================
-- END OF INDEX OPTIMIZATION
-- =========================

