Struktur Modular API Gateway
Setiap modul memiliki namespace dan endpoint yang konsisten. Semua request harus menyertakan tenant_id (bisa dari token JWT atau header) untuk isolasi data.

🔐 1. Auth Module
Untuk login, registrasi perangkat, dan manajemen sesi.

Endpoint	Method	Deskripsi
/auth/login	POST	Login pengguna (username + password)
/auth/logout	POST	Logout dan revoke token
/auth/device/register	POST	Registrasi perangkat baru
/auth/token/refresh	POST	Refresh token JWT
/auth/me	GET	Info pengguna saat ini
🧑‍💼 2. User & Role Module
Endpoint	Method	Deskripsi
/users	GET/POST/PUT/DELETE	CRUD pengguna
/roles	GET/POST/PUT/DELETE	CRUD peran
/permissions	GET	Daftar hak akses
/role-permissions	POST	Assign permission ke role
🏪 3. Tenant & Subscription Module
Endpoint	Method	Deskripsi
/tenants	GET/POST/PUT	Info tenant & update profil
/subscriptions	GET/POST	Langganan & upgrade paket
/features	GET	Daftar fitur add-on
/tenant-features	POST/DELETE	Aktivasi/deaktivasi fitur
/billing	GET	Riwayat tagihan
🏬 4. Branch Module
Endpoint	Method	Deskripsi
/branches	GET/POST/PUT/DELETE	CRUD cabang
/branch-settings	GET/POST/PUT	Pengaturan cabang
📦 5. Inventory Module
Endpoint	Method	Deskripsi
/products	GET/POST/PUT/DELETE	CRUD produk
/product-units	GET/POST/PUT/DELETE	Unit & harga produk
/categories	GET/POST/PUT/DELETE	Kategori produk
/stock-notifications	GET	Notifikasi stok
💰 6. Sales Module
Endpoint	Method	Deskripsi
/sales	GET/POST	Transaksi penjualan
/sales/:id/items	GET	Detail item penjualan
/cash-transactions	GET/POST	Kas masuk/keluar
/employee-loans	GET/POST	Kasbon karyawan
/customer-loans	GET/POST	Kasbon pelanggan
📊 7. Reports Module
Endpoint	Method	Deskripsi
/reports/profit-loss	GET	Laporan laba rugi
/reports/expenses	GET	Laporan pengeluaran
/reports/sales	GET	Laporan penjualan
📣 8. Notification & Support Module
Endpoint	Method	Deskripsi
/notifications	GET	Notifikasi sistem
/support-tickets	GET/POST	Tiket dukungan
/activity-logs	GET	Log aktivitas pengguna
/device-logs	GET	Log perangkat


Platform Management Module (Vendor/Admin)
Modul ini hanya bisa diakses oleh vendor_admins dengan role seperti superadmin atau admin.

🔐 1. Vendor Auth
Endpoint	Method	Deskripsi
/vendor/login	POST	Login admin vendor
/vendor/logout	POST	Logout
/vendor/me	GET	Info admin vendor saat ini
🧑‍💻 2. Vendor Admin Management
Endpoint	Method	Deskripsi
/vendor/admins	GET/POST/PUT/DELETE	CRUD admin vendor
/vendor/admins/:id/audit	GET	Riwayat aksi admin tertentu
🏢 3. Tenant Oversight
Endpoint	Method	Deskripsi
/vendor/tenants	GET	List semua tenant
/vendor/tenants/:id	GET/PUT	Detail & update status tenant
/vendor/tenants/:id/suspend	POST	Suspend tenant
/vendor/tenants/:id/activate	POST	Aktifkan kembali tenant
📦 4. Plan & Feature Management
Endpoint	Method	Deskripsi
/vendor/plans	GET/POST/PUT/DELETE	CRUD paket langganan
/vendor/features	GET/POST/PUT/DELETE	CRUD fitur add-on
/vendor/feature-pricing	PUT	Update harga fitur
📊 5. Audit & Monitoring
Endpoint	Method	Deskripsi
/vendor/audit-actions	GET	Semua log aksi vendor
/vendor/audit-actions/:tenant_id	GET	Log aksi vendor per tenant
/vendor/tenant-activity/:tenant_id	GET	Aktivitas tenant (penjualan, login, dll)
🧾 6. Billing Oversight
Endpoint	Method	Deskripsi
/vendor/billing-records	GET	Semua tagihan
/vendor/billing-records/:tenant_id	GET	Tagihan per tenant
/vendor/billing-records/:id/status	PUT	Update status pembayaran (manual override)
🆘 7. Support Management
Endpoint	Method	Deskripsi
/vendor/support-tickets	GET	Semua tiket dukungan
/vendor/support-tickets/:id/reply	POST	Balas tiket
/vendor/support-tickets/:id/status	PUT	Update status tiket (open, pending, closed)
