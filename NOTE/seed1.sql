-- Paket Langganan
INSERT INTO plans VALUES
  (DEFAULT, 'trial', 'Trial 30 Hari', 0, 0, TRUE, FALSE, 1, 'Gratis selama 30 hari. Maksimal 1 perangkat.'),
  (DEFAULT, 'basic', 'Basic', 25000, 250000, FALSE, FALSE, 1, 'Untuk usaha kecil. Maksimal 1 perangkat.'),
  (DEFAULT, 'multi', 'Multi Device', 50000, 500000, FALSE, FALSE, 3, 'Untuk tim kecil. Maksimal 3 perangkat.'),
  (DEFAULT, 'lifetime', 'Lifetime Access', 0, 0, FALSE, TRUE, 9999, 'Akses selamanya. Bebas jumlah perangkat.');

-- Fitur Add-on
INSERT INTO features VALUES
  (DEFAULT, 'inventory', 'Manajemen Stok', 10000, 100000, 100000, 'Pantau dan kelola stok barang.'),
  (DEFAULT, 'reporting', 'Laporan Keuangan', 15000, 150000, 150000, 'Laporan penjualan dan keuangan.'),
  (DEFAULT, 'kasbon', 'Kasbon Pelanggan', 5000, 50000, 50000, 'Catat hutang pelanggan.');

-- Tenant Contoh
INSERT INTO tenants VALUES
  (DEFAULT, '081234567890', 'Toko Sukses', 'Budi Santoso', '081234567890', 'budi@tokosukses.com', DEFAULT, 'active'),
  (DEFAULT, '089876543210', 'Toko Abadi', 'Siti Aminah', '089876543210', 'siti@abadi.com', DEFAULT, 'active');

-- User Contoh
INSERT INTO users VALUES
  (DEFAULT, '081234567890', 'kasir1', 'hashed_password', 'staff', DEFAULT),
  (DEFAULT, '081234567890', 'owner', 'hashed_password', 'owner', DEFAULT),
  (DEFAULT, '089876543210', 'owner', 'hashed_password', 'owner', DEFAULT);

-- Subscription Contoh
INSERT INTO subscriptions VALUES
  (DEFAULT, '081234567890', 'basic', '2025-01-01', '2025-12-31', FALSE, FALSE, 1, 'active'),
  (DEFAULT, '089876543210', 'lifetime', '2025-08-01', NULL, FALSE, TRUE, 9999, 'active');

-- Invoice Contoh
INSERT INTO invoices VALUES
  (DEFAULT, '081234567890', 'basic', '2025-01-01', '2025-01-07', 250000, FALSE, FALSE, 'paid'),
  (DEFAULT, '081234567890', 'basic', '2025-07-01', '2025-07-07', 90000, FALSE, FALSE, 'paid'),
  (DEFAULT, '089876543210', 'lifetime', '2025-08-01', '2025-08-07', 500000, FALSE, TRUE, 'paid'),
  (DEFAULT, '089876543210', 'lifetime', '2025-08-01', '2025-08-07', 100000, FALSE, TRUE, 'paid');

-- Fitur Aktif
INSERT INTO tenant_features VALUES
  (DEFAULT, '081234567890', 'inventory', '2025-01-01', 'active'),
  (DEFAULT, '081234567890', 'reporting', '2025-07-01', 'active'),
  (DEFAULT, '089876543210', 'inventory', '2025-08-01', 'active');

-- Device Contoh
INSERT INTO devices VALUES
  (DEFAULT, '081234567890', 'device-abc123', 'Kasir Android', DEFAULT);

-- Log Aktivitas
INSERT INTO device_logs VALUES
  (DEFAULT, '081234567890', 'device-abc123', 1, 'login', DEFAULT);

INSERT INTO activity_logs VALUES
  (DEFAULT, '081234567890', 1, 'Melakukan transaksi penjualan', 'sales', DEFAULT);

-- Notifikasi Contoh
INSERT INTO notifications VALUES
  (DEFAULT, '081234567890', 'Langganan akan berakhir', 'Langganan Anda akan berakhir dalam 7 hari.', 'billing', FALSE, DEFAULT);