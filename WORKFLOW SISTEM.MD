:

🧩 Struktur Modular & Multi-Tenant
1. Onboarding Tenant
Input: Nomor HP/email → tenant_code

Proses:

Buat entri di tenants

Buat default tenant_settings, roles, dan users (role: owner)

Assign subscriptions → default trial atau pilihan paket

Registrasi devices pertama kali login

Output: Tenant aktif dengan akses ke dashboard

2. Langganan & Fitur
Langganan:

subscriptions → mengatur masa aktif, perangkat, dan status

billing_records → tagihan otomatis berdasarkan paket

Fitur Add-on:

features → daftar fitur

tenant_features → aktivasi fitur per tenant

3. Manajemen Cabang & Pengguna
Cabang:

branches → data cabang

branch_settings → pengaturan spesifik cabang

Pengguna:

users → role-based access

roles, permissions, role_permissions → kontrol granular

device_logs, activity_logs → audit trail

🔄 Workflow Operasional POS
1. Produk & Inventori
products → per tenant & cabang

product_units → multi-unit & konversi

categories → pengelompokan produk

stock_notifications → alert stok rendah/laris

2. Transaksi Penjualan
penjualan → header transaksi

penjualan_items → detail item

cash_transactions → kas masuk/keluar non-penjualan

employee_loans, customer_loans → kasbon

3. Laporan & Analitik
profit_loss_reports → laba rugi per cabang

expenses, expense_categories → pengeluaran

notifications → sistem alert & info

🔐 Logika Sistem & Validasi
Modul	Logika Utama
Multi-Tenant	Isolasi data via tenant_id di semua tabel
Role-Based Access	users → roles → permissions
Device Management	Validasi max_devices dari subscriptions
Sinkronisasi Offline/Online	UUID di products, penjualan, dll + sync_source
Langganan & Fitur	Validasi status aktif sebelum akses fitur
Audit & Keamanan	device_logs, activity_logs, audit_vendor_actions
⚙️ Workflow Teknis (Simplified)
mermaid
flowchart TD
    A[Registrasi Tenant] --> B[Buat Subscriptions & Settings]
    B --> C[Buat User Owner & Device]
    C --> D[Login ke Sistem]
    D --> E{Langganan Aktif?}
    E -->|Ya| F[Akses Dashboard & Fitur]
    E -->|Tidak| G[Redirect ke Halaman Pembayaran]
    F --> H[Manajemen Produk, Penjualan, Laporan]
    H --> I[Sinkronisasi Offline/Online]