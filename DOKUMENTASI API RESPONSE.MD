Siap, cak! Berikut adalah file dokumentasi lengkap dalam format `.md` yang menggabungkan semua endpoint dari bagian **Vendor Platform Management** dan **Struktur Modular & Multi-Tenant**. Dokumentasi ini cocok untuk digunakan sebagai referensi teknis, onboarding developer, atau dasar Swagger/OpenAPI.

---

# 🧾 SaaS POS Platform API Documentation

Versi: `v1`  
Format: `RESTful JSON`  
Auth: `Bearer Token`

---

## 🔐 Authentication

### `POST /vendor/login`

**Request:**
```json
{
  "username": "admin_vendor",
  "password": "securepassword123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "role": "superadmin"
}
```

---

### `GET /vendor/me`

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": 1,
  "username": "admin_vendor",
  "email": "admin@platform.com",
  "role": "superadmin",
  "created_at": "2025-01-01T10:00:00Z"
}
```

---

## 🧑‍💻 Vendor Admin Management

### `GET /vendor/admins`

**Response:**
```json
[
  {
    "id": 1,
    "username": "admin_vendor",
    "email": "admin@platform.com",
    "role": "superadmin"
  }
]
```

---

### `POST /vendor/admins`

**Request:**
```json
{
  "username": "new_admin",
  "email": "new@platform.com",
  "password": "securepass",
  "role": "admin"
}
```

**Response:**
```json
{
  "message": "Admin created successfully",
  "id": 3
}
```

---

## 🏢 Tenant Management

### `GET /vendor/tenants`

**Response:**
```json
[
  {
    "id": 101,
    "tenant_code": "081234567890",
    "tenant_name": "Toko Sukses",
    "status": "active"
  }
]
```

---

### `PUT /vendor/tenants/:id`

**Request:**
```json
{
  "status": "suspended"
}
```

**Response:**
```json
{
  "message": "Tenant status updated"
}
```

---

### `POST /tenants`

**Request:**
```json
{
  "tenant_code": "081234567890",
  "tenant_name": "Toko Sukses",
  "owner_name": "Budi Santoso",
  "email": "budi@tokosukses.com",
  "phone": "081234567890",
  "plan_id": 1,
  "modules": [1, 2, 3]
}
```

**Response:**
```json
{
  "message": "Tenant created successfully",
  "tenant_id": 101
}
```

---

### `GET /tenants/:id`

**Response:**
```json
{
  "tenant_id": 101,
  "tenant_code": "081234567890",
  "tenant_name": "Toko Sukses",
  "owner_name": "Budi Santoso",
  "email": "budi@tokosukses.com",
  "phone": "081234567890",
  "plan": {
    "id": 1,
    "name": "Basic"
  },
  "modules": [
    { "id": 1, "name": "Kasir" },
    { "id": 2, "name": "Stok" },
    { "id": 3, "name": "Laporan" }
  ],
  "status": "active"
}
```

---

## 🧱 Modules

### `GET /modules`

**Response:**
```json
[
  {
    "id": 1,
    "name": "Kasir",
    "description": "Transaksi penjualan dan pembayaran"
  }
]
```

---

### `POST /modules`

**Request:**
```json
{
  "name": "Pelanggan",
  "description": "Manajemen data pelanggan"
}
```

**Response:**
```json
{
  "message": "Module created",
  "id": 4
}
```

---

### `PUT /tenants/:id/modules`

**Request:**
```json
{
  "modules": [1, 2, 4]
}
```

**Response:**
```json
{
  "message": "Modules updated for tenant"
}
```

---

## 🛂 Role-Based Access Control (RBAC)

### `GET /roles`

**Response:**
```json
[
  {
    "id": 1,
    "name": "owner",
    "permissions": ["view_sales", "manage_users"]
  }
]
```

---

### `POST /roles`

**Request:**
```json
{
  "name": "inventory_manager",
  "permissions": ["view_stock", "update_stock"]
}
```

**Response:**
```json
{
  "message": "Role created",
  "id": 3
}
```

---

### `PUT /tenants/:id/users/:user_id/role`

**Request:**
```json
{
  "role_id": 2
}
```

**Response:**
```json
{
  "message": "User role updated"
}
```

---

## ⚙️ Tenant Configuration

### `GET /tenants/:id/config`

**Response:**
```json
{
  "timezone": "Asia/Jakarta",
  "currency": "IDR",
  "language": "id",
  "offline_mode": true,
  "sync_interval_minutes": 15
}
```

---

### `PUT /tenants/:id/config`

**Request:**
```json
{
  "timezone": "Asia/Jakarta",
  "currency": "IDR",
  "language": "id",
  "offline_mode": true,
  "sync_interval_minutes": 10
}
```

**Response:**
```json
{
  "message": "Configuration updated"
}
```

---

## 📦 Plans & Features

### `GET /vendor/plans`

**Response:**
```json
[
  {
    "id": 1,
    "plan_name": "Basic",
    "price_monthly": 25000,
    "price_yearly": 250000
  }
]
```

---

### `POST /vendor/plans`

**Request:**
```json
{
  "plan_name": "Premium",
  "price_monthly": 75000,
  "price_yearly": 750000,
  "is_trial": false,
  "is_lifetime": false,
  "max_devices": 5,
  "description": "Untuk usaha menengah"
}
```

**Response:**
```json
{
  "message": "Plan created",
  "id": 5
}
```

---

### `GET /vendor/features`

**Response:**
```json
[
  {
    "id": 1,
    "feature_name": "Manajemen Stok",
    "price_monthly": 10000
  }
]
```

---

### `PUT /vendor/feature-pricing`

**Request:**
```json
{
  "feature_id": 1,
  "price_monthly": 12000,
  "price_yearly": 120000
}
```

**Response:**
```json
{
  "message": "Feature pricing updated"
}
```

---

## 📊 Audit & Monitoring

### `GET /vendor/audit-actions`

**Response:**
```json
[
  {
    "admin_id": 1,
    "action": "Suspend tenant",
    "tenant_id": 102,
    "timestamp": "2025-08-05T09:00:00Z"
  }
]
```

---

### `GET /vendor/tenant-activity/:tenant_id`

**Response:**
```json
{
  "tenant_id": 101,
  "logins": 12,
  "sales_today": 34,
  "last_activity": "2025-08-05T08:45:00Z"
}
```

---

## 🧾 Billing

### `GET /vendor/billing-records/:tenant_id`

**Response:**
```json
[
  {
    "invoice_date": "2025-01-01",
    "amount": 250000,
    "status": "paid"
  }
]
```

---

### `PUT /vendor/billing-records/:id/status`

**Request:**
```json
{
  "status": "paid"
}
```

**Response:**
```json
{
  "message": "Billing status updated"
}
```

---

## 🆘 Support

### `GET /vendor/support-tickets`

**Response:**
```json
[
  {
    "id": 1,
    "tenant_id": 101,
    "subject": "Tidak bisa login",
    "status": "open"
  }
]
```

---

### `POST /vendor/support-tickets/:id/reply`

**Request:**
```json
{
  "message": "Silakan reset password melalui menu pengaturan."
}
```

**Response:**
```json
{
  "message": "Reply sent"
}
```

---

### `PUT /vendor/support-tickets/:id/status`

**Request:**
```json
{
  "status": "closed"
}
```

**Response:**
```json
{
  "message": "Ticket status updated"
}
```
