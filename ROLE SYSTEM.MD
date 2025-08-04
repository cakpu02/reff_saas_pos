Berikut Role Sisttem Saas POS

✅ Struktur inti: tenants, branches, users

✅ Modul langganan: plans, subscriptions, billing_records

✅ Fitur add-on: features, tenant_features

✅ Pengaturan fleksibel: tenant_settings, branch_settings

✅ Logging & notifikasi: device_logs, activity_logs, notifications

✅ Seed data awal untuk semua entitas utama

✅ Sistem role & permission: roles, permissions, role_permissions

✅ Modul vendor: vendor_admins, audit_vendor_actions, support_tickets

📦 File: saas_pos_full.sql

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

🌱 Seed Data (Contoh)

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

🔄 Alur Kerja Sistem

1. Pendaftaran Tenant

Tenant mendaftar melalui aplikasi atau website.

Data tenant disimpan di tabel tenants.

Tenant otomatis mendapatkan status trial selama 30 hari dengan fitur default dari paket yang dipilih (tanpa add-on).

Contoh:

Tenant “Toko Sukses” memilih paket “Basic”.

Sistem membuat entri di tabel subscriptions:

INSERT INTO subscriptions (tenant_code, plan_code, start_date, end_date, is_trial, is_lifetime, max_devices, status) VALUES
('081234567890', 'basic', '2025-08-01', '2025-08-31', TRUE, FALSE, 1, 'active');

2. Skema Langganan

Setelah masa trial selesai, tenant bisa memilih model langganan:

Bulanan

Tahunan

Lifetime

Data langganan diperbarui di tabel subscriptions.

Contoh:

Tenant “Toko Sukses” memilih langganan tahunan setelah masa trial.

Sistem memperbarui entri di tabel subscriptions:

UPDATE subscriptions SET start_date = '2025-09-01', end_date = '2026-08-31', is_trial = FALSE, is_lifetime = FALSE, max_devices = 1 WHERE tenant_code = '081234567890';

3. Aktivasi Fitur Add-On

Tenant bisa membeli fitur tambahan di tabel features.

Aktivasi fitur disimpan di tabel tenant_features.

Contoh:

Tenant “Toko Sukses” membeli fitur “Manajemen Stok”.

Sistem membuat entri di tabel tenant_features:

INSERT INTO tenant_features (tenant_code, feature_code, activated_at, status) VALUES
('081234567890', 'inventory', DEFAULT, 'active');

4. Pengaturan Tenant

Tenant bisa mengatur preferensi di tabel tenant_settings.

Cabang bisa mengatur preferensi di tabel branch_settings.

5. Pengaturan User

Tenant membuat user di tabel users.

User diberi role di tabel roles.

Role memiliki hak akses di tabel role_permissions.

🔄 Alur Logika Backend

1. Pendaftaran Tenant

Endpoint: POST /api/tenants/register

Logika:

Simpan data tenant ke tabel tenants

Buat entri subscriptions dengan status trial 30 hari

Aktifkan fitur default dari paket (tanpa add-on)

Buat role default: “Admin”, “Kasir”

Buat user pertama sebagai “Admin”

2. Langganan & Add-On

Endpoint: POST /api/subscriptions/upgrade

Logika:

Update entri subscriptions sesuai pilihan (bulanan/tahunan/lifetime)

Tambahkan billing record

Aktifkan fitur tambahan di tenant_features

3. Pengaturan Role & Permission

Endpoint: POST /api/roles/create

Logika:

Simpan role baru di roles

Mapping permission di role_permissions

Endpoint: POST /api/users/create

Logika:

Simpan user baru di users

Assign role_id sesuai role yang dipilih

4. Validasi Hak Akses

Middleware: checkPermission(permission_key)

Logika:

Ambil role_id dari user

Ambil daftar permission_key dari role_permissions

Jika tidak punya permission → return 403 Forbidden

Contoh:

if (!user.permissions.includes('delete_product')) {
  return res.status(403).json({ message: 'Akses ditolak' });
}

🛡️ Catatan Tambahan

Soft Delete: Gunakan is_deleted untuk data sensitif

Audit Log: Catat aktivitas penting di activity_logs

Rate Limiting: Lindungi endpoint dari abuse

Multi-Tenant Isolation: Pastikan semua query terfilter berdasarkan tenant_code

📝 Catatan Tambahan

Keamanan Data: Pastikan validasi dilakukan di backend untuk mencegah bypass.

Audit Log: Tambahkan logging untuk mencatat aktivitas penting.

Soft Delete: Gunakan sistem soft delete untuk data sensitif.

Scalability: Desain sistem agar bisa menangani tenant besar dengan banyak cabang dan user.

🧭 Struktur Navigasi Dashboard Vendor

Berikut layout menu utama yang bisa kamu pakai:

Menu Utama

Submenu / Fungsi

Dashboard

Ringkasan tenant aktif, pendapatan, fitur populer

Tenants

Lihat, cari, suspend, atau ubah data tenant

Subscriptions

Pantau status langganan, upgrade, masa trial

Billing

Lihat tagihan, status pembayaran, generate invoice

Plans & Features

Kelola paket langganan dan fitur add-on

Activity Logs

Audit aktivitas tenant dan admin

Support Tickets

Tanggapi tiket bantuan dari tenant

Settings

Atur konfigurasi global, rate limit, soft delete

Admin Users

Kelola akun admin vendor (superadmin, support, dll)

📊 Tampilan Dashboard Utama

Berikut ide tampilan awal dashboard vendor:

🔹 Statistik Ringkas (Top Cards)

Jumlah tenant aktif

Total pendapatan bulan ini

Jumlah fitur aktif

Jumlah tiket support terbuka

📈 Grafik & Tren

Grafik pertumbuhan tenant per bulan

Grafik pendapatan per paket langganan

Fitur paling sering diaktifkan

📋 Tabel Ringkasan

5 tenant terbaru

5 tagihan overdue

5 tiket support terbaru

🛠️ Fitur Kontrol Vendor

Suspend tenant (ubah status jadi inactive)

Reset password tenant

Kirim notifikasi massal ke semua tenant

Export data tenant ke CSV/Excel

Filter tenant berdasarkan paket/langganan

🔐 Hak Akses Admin Vendor

Bisa pakai role seperti:

superadmin: akses penuh

support: hanya bisa lihat tenant & tanggapi tiket

finance: hanya bisa lihat billing & subscriptions

🔌 Desain Endpoint API Vendor

Berikut adalah rancangan endpoint untuk dashboard vendor, lengkap dengan metode dan fungsinya:

1. Dashboard Statistik

Endpoint

Method

Fungsi

/api/vendor/dashboard/summary

GET

Ambil statistik ringkas: jumlah tenant, pendapatan, fitur aktif

/api/vendor/dashboard/trends

GET

Ambil data grafik tren: pertumbuhan tenant, pendapatan, fitur populer

2. Manajemen Tenant

Endpoint

Method

Fungsi

/api/vendor/tenants

GET

List semua tenant

/api/vendor/tenants/:code

GET

Detail tenant berdasarkan tenant_code

/api/vendor/tenants/:code/suspend

POST

Suspend tenant

/api/vendor/tenants/:code/reset-password

POST

Reset password tenant

/api/vendor/tenants/export

GET

Export data tenant ke CSV/Excel

3. Langganan & Billing

Endpoint

Method

Fungsi

/api/vendor/subscriptions

GET

List semua langganan tenant

/api/vendor/billing

GET

List billing record

/api/vendor/billing/:id/invoice

GET

Generate invoice PDF

4. Manajemen Paket & Fitur

Endpoint

Method

Fungsi

/api/vendor/plans

GET

List semua paket langganan

/api/vendor/features

GET

List semua fitur add-on

/api/vendor/features/:code/tenants

GET

Lihat tenant yang mengaktifkan fitur tertentu

5. Log Aktivitas & Tiket Bantuan

Endpoint

Method

Fungsi

/api/vendor/logs/activity

GET

Audit log aktivitas tenant dan admin

/api/vendor/support-tickets

GET

List tiket bantuan

/api/vendor/support-tickets/:id/reply

POST

Balas tiket bantuan

6. Manajemen Admin Vendor

Endpoint

Method

Fungsi

/api/vendor/admins

GET

List admin vendor

/api/vendor/admins/create

POST

Tambah admin baru

/api/vendor/admins/:id/update-role

PUT

Ubah role admin

🖥️ Mockup UI Dashboard Vendor (Wireframe Kasar)

Berikut ide layout UI dashboard vendor:

🔹 Header

Logo SaaS POS

Nama admin & tombol logout

🔹 Sidebar Menu

Dashboard

Tenants

Subscriptions

Billing

Plans & Features

Activity Logs

Support Tickets

Settings

Admin Users

🔹 Halaman Dashboard Utama

Top Cards:

🟩 Jumlah Tenant Aktif

💰 Pendapatan Bulan Ini

🧩 Fitur Aktif

🛠️ Tiket Support Terbuka

Grafik:

📈 Pertumbuhan Tenant (Line Chart)

📊 Pendapatan per Paket (Bar Chart)

🔥 Fitur Populer (Pie Chart)

Tabel Ringkasan:

5 Tenant Terbaru

5 Tagihan Overdue

5 Tiket Support Terbaru

Kalau ada yang perlu ditambahkan atau diperjelas, tinggal bilang aja cak!

#rolevendordantenant