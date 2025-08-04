-- =============================================
-- 1. Master Fitur
-- =============================================
CREATE TABLE fitur (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kode_fitur VARCHAR(50) UNIQUE NOT NULL,
  nama_fitur VARCHAR(100) NOT NULL,
  deskripsi TEXT
);

-- =============================================
-- 2. Daftar Paket (trial, berlangganan, lifetime)
-- =============================================
CREATE TABLE paket (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama_paket VARCHAR(100) NOT NULL,
  segmen ENUM('toko','niaga','grossir') NOT NULL,
  harga DECIMAL(12,2) DEFAULT 0,
  is_trial BOOLEAN DEFAULT FALSE,
  durasi_hari_trial INT DEFAULT NULL,
  is_lifetime BOOLEAN DEFAULT FALSE,
  max_device INT DEFAULT 1
);

-- =============================================
-- 3. Mapping Fitur dalam Setiap Paket
-- =============================================
CREATE TABLE paket_fitur (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_paket INT NOT NULL,
  id_fitur INT NOT NULL,
  FOREIGN KEY (id_paket) REFERENCES paket(id) ON DELETE CASCADE,
  FOREIGN KEY (id_fitur) REFERENCES fitur(id) ON DELETE CASCADE
);

-- =============================================
-- 4. Master Tenant
-- =============================================
CREATE TABLE tenant (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  alamat TEXT,
  kontak_admin VARCHAR(100) NOT NULL UNIQUE,
  segmen ENUM('toko','niaga','grossir') NOT NULL,
  logo_path VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 5. Tenant-Paket Aktif
-- =============================================
CREATE TABLE tenant_paket (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_paket INT NOT NULL,
  tanggal_mulai DATE NOT NULL,
  tanggal_akhir DATE DEFAULT NULL,
  status ENUM('aktif','expired') DEFAULT 'aktif',
  FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON DELETE CASCADE,
  FOREIGN KEY (id_paket) REFERENCES paket(id) ON DELETE CASCADE
);

-- =============================================
-- 6. Fitur yang Aktif di Tenant (termasuk addon)
-- =============================================
CREATE TABLE tenant_fitur (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_fitur INT NOT NULL,
  status ENUM('aktif','nonaktif') DEFAULT 'aktif',
  source ENUM('paket','addon','promo') DEFAULT 'paket',
  FOREIGN KEY (id_tenant) REFERENCES tenant(id) ON DELETE CASCADE,
  FOREIGN KEY (id_fitur) REFERENCES fitur(id) ON DELETE CASCADE
);

-- =============================================
-- 7. Cabang (untuk multi-cabang)
-- =============================================
CREATE TABLE cabang (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  nama_cabang VARCHAR(100) NOT NULL,
  alamat TEXT,
  kode_cabang VARCHAR(20) UNIQUE,
  is_aktif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

-- =============================================
-- 8. User (per tenant & cabang)
-- =============================================
CREATE TABLE user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_cabang INT DEFAULT NULL,
  username VARCHAR(50) NOT NULL,
  nama VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('owner', 'admin', 'kasir') DEFAULT 'kasir',
  is_aktif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_cabang) REFERENCES cabang(id),
  UNIQUE KEY unique_username_per_tenant (id_tenant, username)
);

-- =============================================
-- 9. Billing & Addon
-- =============================================
CREATE TABLE billing (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_paket INT DEFAULT NULL,
  tipe ENUM('trial','berlangganan','lifetime','addon') NOT NULL,
  tipe_langganan ENUM('bulanan','tahunan') DEFAULT NULL,
  periode VARCHAR(7),
  tanggal_tagihan DATE NOT NULL,
  tanggal_jatuh_tempo DATE NOT NULL,
  total_tagihan DECIMAL(12,2) NOT NULL DEFAULT 0,
  status ENUM('unpaid','paid','cancelled') DEFAULT 'unpaid',
  keterangan TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_paket) REFERENCES paket(id)
);

CREATE TABLE billing_addon (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_billing INT NOT NULL,
  nama_addon VARCHAR(100) NOT NULL,
  kode_fitur VARCHAR(50),
  jumlah DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (id_billing) REFERENCES billing(id) ON DELETE CASCADE
);

-- =============================================
-- 10. Device Limitasi
-- =============================================
CREATE TABLE user_device (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_user INT NOT NULL,
  device_id VARCHAR(255) NOT NULL,
  user_agent TEXT,
  last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_aktif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_user) REFERENCES user(id),
  UNIQUE KEY unique_user_device (id_user, device_id)
);

-- =============================================
-- 11. Logging & Audit
-- =============================================
CREATE TABLE log_aktivitas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_user INT NOT NULL,
  id_tenant INT NOT NULL,
  modul VARCHAR(100),
  aksi VARCHAR(50),
  deskripsi TEXT,
  waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_user) REFERENCES user(id),
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE log_login (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_user INT DEFAULT NULL,
  id_tenant INT DEFAULT NULL,
  username_input VARCHAR(100),
  kontak_admin_input VARCHAR(100),
  status ENUM('berhasil', 'gagal') NOT NULL,
  ip_address VARCHAR(50),
  user_agent TEXT,
  waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  keterangan TEXT
);

-- =============================================
-- 12. Pengaturan Nota Tenant & Cabang
-- =============================================
CREATE TABLE setting_tenant (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL UNIQUE,
  nama_toko_cetak VARCHAR(100),
  alamat_cetak TEXT,
  kontak_cetak VARCHAR(100),
  footer_nota TEXT,
  logo_nota_path VARCHAR(255),
  tipe_pajak ENUM('non', 'include', 'exclude') DEFAULT 'non',
  default_diskon_persen DECIMAL(5,2) DEFAULT 0.00,
  default_printer VARCHAR(100),
  kertas_nota ENUM('58mm', '80mm', 'A4') DEFAULT '58mm',
  auto_print BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE setting_cabang (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_cabang INT NOT NULL UNIQUE,
  nama_cetak VARCHAR(100),
  alamat_cetak TEXT,
  kontak_cetak VARCHAR(100),
  footer_nota TEXT,
  logo_nota_path VARCHAR(255),
  default_printer VARCHAR(100),
  kertas_nota ENUM('58mm', '80mm', 'A4') DEFAULT '58mm',
  auto_print BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_cabang) REFERENCES cabang(id)
);

-- =============================================
-- 13. Notifikasi
-- =============================================
CREATE TABLE notifikasi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_user INT DEFAULT NULL,
  jenis ENUM('billing', 'piutang', 'stok', 'sistem') NOT NULL,
  judul VARCHAR(200) NOT NULL,
  pesan TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  waktu_kirim DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_user) REFERENCES user(id) ON DELETE SET NULL
);

-- =============================================
-- Tambahan Tabel Master & Transaksi POS
-- =============================================

CREATE TABLE produk_kategori (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  nama_kategori VARCHAR(100) NOT NULL,
  deskripsi TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE produk_satuan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  nama_satuan VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE produk (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  kode_produk VARCHAR(50) NOT NULL,
  nama_produk VARCHAR(100) NOT NULL,
  id_kategori INT DEFAULT NULL,
  id_satuan INT DEFAULT NULL,
  harga_beli DECIMAL(12,2) DEFAULT 0,
  harga_jual DECIMAL(12,2) DEFAULT 0,
  stok INT DEFAULT 0,
  stok_minimum INT DEFAULT 0,
  is_aktif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_kategori) REFERENCES produk_kategori(id),
  FOREIGN KEY (id_satuan) REFERENCES produk_satuan(id)
);

CREATE TABLE pelanggan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  nama VARCHAR(100) NOT NULL,
  kontak VARCHAR(100),
  alamat TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE supplier (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  nama VARCHAR(100) NOT NULL,
  kontak VARCHAR(100),
  alamat TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE penjualan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_cabang INT DEFAULT NULL,
  id_user INT DEFAULT NULL,
  id_pelanggan INT DEFAULT NULL,
  tanggal DATETIME NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  diskon DECIMAL(12,2) DEFAULT 0,
  pajak DECIMAL(12,2) DEFAULT 0,
  grand_total DECIMAL(12,2) NOT NULL,
  status ENUM('draft','selesai','batal') DEFAULT 'selesai',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_cabang) REFERENCES cabang(id),
  FOREIGN KEY (id_user) REFERENCES user(id),
  FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id)
);

CREATE TABLE penjualan_detail (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_penjualan INT NOT NULL,
  id_produk INT NOT NULL,
  qty INT NOT NULL,
  harga DECIMAL(12,2) NOT NULL,
  diskon DECIMAL(12,2) DEFAULT 0,
  subtotal DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (id_penjualan) REFERENCES penjualan(id) ON DELETE CASCADE,
  FOREIGN KEY (id_produk) REFERENCES produk(id)
);

CREATE TABLE pembelian (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_cabang INT DEFAULT NULL,
  id_user INT DEFAULT NULL,
  id_supplier INT DEFAULT NULL,
  tanggal DATETIME NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  diskon DECIMAL(12,2) DEFAULT 0,
  pajak DECIMAL(12,2) DEFAULT 0,
  grand_total DECIMAL(12,2) NOT NULL,
  status ENUM('draft','selesai','batal') DEFAULT 'selesai',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_cabang) REFERENCES cabang(id),
  FOREIGN KEY (id_user) REFERENCES user(id),
  FOREIGN KEY (id_supplier) REFERENCES supplier(id)
);

CREATE TABLE pembelian_detail (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_pembelian INT NOT NULL,
  id_produk INT NOT NULL,
  qty INT NOT NULL,
  harga DECIMAL(12,2) NOT NULL,
  diskon DECIMAL(12,2) DEFAULT 0,
  subtotal DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (id_pembelian) REFERENCES pembelian(id) ON DELETE CASCADE,
  FOREIGN KEY (id_produk) REFERENCES produk(id)
);

CREATE TABLE kas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_cabang INT DEFAULT NULL,
  tipe ENUM('masuk','keluar') NOT NULL,
  nominal DECIMAL(12,2) NOT NULL,
  keterangan TEXT,
  tanggal DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_cabang) REFERENCES cabang(id)
);

CREATE TABLE stok_mutasi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_cabang INT DEFAULT NULL,
  id_produk INT NOT NULL,
  tipe ENUM('masuk','keluar','penyesuaian') NOT NULL,
  qty INT NOT NULL,
  keterangan TEXT,
  tanggal DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_cabang) REFERENCES cabang(id),
  FOREIGN KEY (id_produk) REFERENCES produk(id)
);

CREATE TABLE stok_opname (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_cabang INT DEFAULT NULL,
  id_produk INT NOT NULL,
  stok_fisik INT NOT NULL,
  stok_sistem INT NOT NULL,
  selisih INT NOT NULL,
  keterangan TEXT,
  tanggal DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_cabang) REFERENCES cabang(id),
  FOREIGN KEY (id_produk) REFERENCES produk(id)
);

CREATE TABLE kasbon (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_user INT NOT NULL,
  nominal DECIMAL(12,2) NOT NULL,
  keterangan TEXT,
  tanggal DATETIME NOT NULL,
  status ENUM('belum','lunas') DEFAULT 'belum',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_user) REFERENCES user(id)
);

CREATE TABLE promo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  nama VARCHAR(100) NOT NULL,
  tipe ENUM('diskon','bonus') NOT NULL,
  nilai DECIMAL(12,2) NOT NULL,
  tanggal_mulai DATE NOT NULL,
  tanggal_akhir DATE NOT NULL,
  is_aktif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE promo_detail (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_promo INT NOT NULL,
  id_produk INT NOT NULL,
  FOREIGN KEY (id_promo) REFERENCES promo(id) ON DELETE CASCADE,
  FOREIGN KEY (id_produk) REFERENCES produk(id)
);

CREATE TABLE retur_penjualan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_penjualan INT NOT NULL,
  tanggal DATETIME NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_penjualan) REFERENCES penjualan(id)
);

CREATE TABLE retur_penjualan_detail (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_retur_penjualan INT NOT NULL,
  id_produk INT NOT NULL,
  qty INT NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (id_retur_penjualan) REFERENCES retur_penjualan(id) ON DELETE CASCADE,
  FOREIGN KEY (id_produk) REFERENCES produk(id)
);

CREATE TABLE retur_pembelian (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_pembelian INT NOT NULL,
  tanggal DATETIME NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_pembelian) REFERENCES pembelian(id)
);

CREATE TABLE retur_pembelian_detail (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_retur_pembelian INT NOT NULL,
  id_produk INT NOT NULL,
  qty INT NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (id_retur_pembelian) REFERENCES retur_pembelian(id) ON DELETE CASCADE,
  FOREIGN KEY (id_produk) REFERENCES produk(id)
);

CREATE TABLE backup_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  tipe ENUM('manual','otomatis') NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE audit_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_user INT DEFAULT NULL,
  aksi VARCHAR(100) NOT NULL,
  deskripsi TEXT,
  waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_user) REFERENCES user(id)
);

CREATE TABLE metode_hpp (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  metode ENUM('FIFO','LIFO','AVERAGE') NOT NULL,
  is_aktif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE akun (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  kode_akun VARCHAR(20) NOT NULL,
  nama_akun VARCHAR(100) NOT NULL,
  tipe ENUM('aset','kewajiban','modal','pendapatan','beban') NOT NULL,
  is_aktif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE jurnal (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  tanggal DATE NOT NULL,
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

CREATE TABLE jurnal_detail (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_jurnal INT NOT NULL,
  id_akun INT NOT NULL,
  tipe ENUM('debet','kredit') NOT NULL,
  nominal DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (id_jurnal) REFERENCES jurnal(id) ON DELETE CASCADE,
  FOREIGN KEY (id_akun) REFERENCES akun(id)
);

CREATE TABLE saldo_awal (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  id_akun INT NOT NULL,
  nominal DECIMAL(12,2) NOT NULL,
  tahun INT NOT NULL,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id),
  FOREIGN KEY (id_akun) REFERENCES akun(id)
);

CREATE TABLE jurnal_template (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tenant INT NOT NULL,
  nama_template VARCHAR(100) NOT NULL,
  deskripsi TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tenant) REFERENCES tenant(id)
);

-- =============================================
-- SEED DATA CONTOH
-- =============================================

-- Fitur
INSERT INTO fitur (kode_fitur, nama_fitur, deskripsi) VALUES
('POS_BASIC', 'POS Kasir', 'Transaksi kasir dasar'),
('STOK', 'Manajemen Stok', 'Pantau stok barang masuk/keluar'),
('LAPORAN', 'Laporan Penjualan', 'Laporan transaksi dan performa'),
('AKUNTANSI', 'Modul Akuntansi', 'Pencatatan jurnal dan buku besar');

-- Paket
INSERT INTO paket (nama_paket, segmen, harga, is_trial, durasi_hari_trial, is_lifetime, max_device) VALUES
('Trial Toko', 'toko', 0, TRUE, 30, FALSE, 1),
('Trial Niaga', 'niaga', 0, TRUE, 30, FALSE, 1),
('Trial Grossir', 'grossir', 0, TRUE, 30, FALSE, 1),
('Basic Toko', 'toko', 99000, FALSE, NULL, FALSE, 2),
('Basic Niaga', 'niaga', 149000, FALSE, NULL, FALSE, 3),
('Basic Grossir', 'grossir', 199000, FALSE, NULL, FALSE, 5),
('Lifetime Toko', 'toko', 999000, FALSE, NULL, TRUE, 2),
('Lifetime Grossir', 'grossir', 1999000, FALSE, NULL, TRUE, 5);

-- Paket-Fitur Mapping (contoh, sesuaikan id_paket/id_fitur sesuai urutan auto-increment)
INSERT INTO paket_fitur (id_paket, id_fitur) VALUES
(1, 1), (1, 2), (1, 3),  -- Trial Toko
(4, 1), (4, 2), (4, 3),  -- Basic Toko
(7, 1), (7, 2), (7, 3),  -- Lifetime Toko
(3, 1), (3, 2), (3, 3), (3, 4),     -- Trial Grossir
(6, 1), (6, 2), (6, 3), (6, 4),     -- Basic Grossir
(8, 1), (8, 2), (8, 3), (8, 4);     -- Lifetime Grossir

-- Tenant
INSERT INTO tenant (nama, alamat, kontak_admin, segmen, logo_path) VALUES
('Toko Sejahtera', 'Jl. Merdeka 123', 'admin@toko.com', 'toko', '/uploads/logo/toko_sejahtera.png');

-- Cabang
INSERT INTO cabang (id_tenant, nama_cabang, alamat, kode_cabang)
VALUES (1, 'Cabang Utama', 'Jl. Raya No.1', 'CBG001');

-- User
INSERT INTO user (id_tenant, id_cabang, username, nama, email, password_hash, role)
VALUES
(1, NULL, 'owner1', 'Pemilik Usaha', 'owner@email.com', '$2a$10$hashowner', 'owner'),
(1, 1, 'admin1', 'Admin Cabang', 'admin@email.com', '$2a$10$hashadmin', 'admin'),
(1, 1, 'kasir1', 'Kasir Toko', 'kasir@email.com', '$2a$10$hashkasir', 'kasir');

-- Tenant Paket
INSERT INTO tenant_paket (id_tenant, id_paket, tanggal_mulai, tanggal_akhir, status)
VALUES (1, 4, '2025-08-01', NULL, 'aktif');

-- Tenant Fitur (paket)
INSERT INTO tenant_fitur (id_tenant, id_fitur, status, source)
VALUES (1, 1, 'aktif', 'paket'), (1, 2, 'aktif', 'paket'), (1, 3, 'aktif', 'paket');

-- Billing
INSERT INTO billing (id_tenant, id_paket, tipe, tipe_langganan, periode, tanggal_tagihan, tanggal_jatuh_tempo, total_tagihan, status)
VALUES (1, 4, 'berlangganan', 'bulanan', '2025-08', '2025-08-01', '2025-08-10', 99000, 'unpaid');

-- Billing Addon
INSERT INTO billing_addon (id_billing, nama_addon, kode_fitur, jumlah)
VALUES (1, 'Modul Akuntansi', 'AKUNTANSI', 25000);

-- User Device
INSERT INTO user_device (id_user, device_id, user_agent)
VALUES (1, 'dev-abc123', 'Mozilla/5.0 (Android 10) Chrome/103.0');

-- Log Aktivitas
INSERT INTO log_aktivitas (id_user, id_tenant, modul, aksi, deskripsi)
VALUES (1, 1, 'penjualan', 'tambah', 'Menambah transaksi ID 123');

-- Log Login
INSERT INTO log_login (id_user, id_tenant, username_input, kontak_admin_input, status, ip_address, user_agent, keterangan)
VALUES (1, 1, 'kasir1', 'TKA123', 'berhasil', '192.168.0.2', 'Mozilla/5.0', 'Login sukses');

-- Setting Tenant
INSERT INTO setting_tenant (
  id_tenant, nama_toko_cetak, alamat_cetak, kontak_cetak,
  footer_nota, logo_nota_path, tipe_pajak, default_diskon_persen,
  default_printer, kertas_nota, auto_print
) VALUES (
  1, 'Toko Nafalin Cab. Utama', 'Jl. Merdeka No. 99', '08123456789',
  'Terima kasih telah berbelanja!\nNafalin POS', '/uploads/logo_nota1.png',
  'include', 5.00, 'epson-001', '58mm', TRUE
);

-- Setting Cabang
INSERT INTO setting_cabang (
  id_cabang, nama_cetak, alamat_cetak, kontak_cetak,
  footer_nota, logo_nota_path, default_printer, kertas_nota, auto_print
) VALUES (
  1, 'Nafalin Cab. Utama', 'Jl. Raya No.1', '081298765432',
  'Terima kasih belanja di cabang kami!', '/uploads/logo-pasar.png',
  'epson-cab2', '58mm', TRUE
);

-- Notifikasi
INSERT INTO notifikasi (id_tenant, id_user, jenis, judul, pesan) VALUES
(1, 2, 'billing', 'Tagihan Jatuh Tempo', 'Tagihan Anda akan jatuh tempo pada 5 Agustus 2025. Harap segera lakukan pembayaran.'),
(1, NULL, 'stok', 'Stok Barang Menipis', 'Produk "Air Mineral 600ml" tersisa kurang dari 10 pcs di Gudang Utama.'),
(1, 2, 'piutang', 'Piutang Jatuh Tempo', 'Pelanggan Budi memiliki piutang yang jatuh tempo hari ini.');