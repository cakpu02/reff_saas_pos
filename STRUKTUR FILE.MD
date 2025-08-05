Struktur Folder Backend (Node.js + Express + Sequelize)
saas-pos-backend/
├── src/
│   ├── config/                  # Konfigurasi global (DB, JWT, RBAC, dll)
│   ├── jobs/                    # Queue & background jobs (e.g. sync, email)
│   ├── middleware/              # Auth, RBAC, error handler, logger
│   ├── models/                  # Sequelize models (multi-tenant aware)
│   ├── repositories/            # Abstraksi DB access (untuk scalability)
│   ├── services/                # Business logic (sync engine, file service)
│   ├── controllers/            # Route handlers
│   ├── routes/                  # Express routes (modular per feature)
│   ├── utils/                   # Helper functions (UUID, file ops, etc)
│   ├── uploads/                 # File storage (static or via CDN)
│   │   ├── tenants{kode}/
│   │   │   ├── logo/
│   │   │   ├── products/
│   │   │   └── doc/
│   │   └── vendor/
│   │       ├── logo/
│   │       └── doc/
│   ├── sync/                    # Offline-first sync engine
│   │   ├── conflictResolver.js
│   │   ├── syncManager.js
│   │   └── syncQueue.js
│   └── app.js                   # Entry point Express
├── .env                         # Environment variables
├── package.json
└── README.md


🔐 Auth & RBAC
JWT Middleware: Validasi token dan extract tenant/user info
Role-based Access: Middleware per route (admin, kasir, owner, dll)
Multi-tenant Isolation: Tenant ID di setiap query dan token

🔄 Sync Engine (Offline-first)
UUID: Sebagai primary key untuk semua data
sync_source: Menandai asal perubahan (mobile, web, sync)
Conflict Resolver: Strategi last-write-wins, merge, atau manual review
Queue System: Gunakan BullMQ atau Agenda untuk job scheduling

📦 File Storage
Gunakan multer untuk upload
Struktur folder sesuai contoh kamu
Bisa diatur untuk pindah ke S3 atau Cloudinary jika butuh CDN

js
// Contoh path generator
function getUploadPath(tenantCode, type, filename) {
  return `/uploads/tenants${tenantCode}/${type}/${filename}`;
}

🧩 Modular Routing (Contoh)
routes/
├── auth.js
├── tenant.js
├── product.js
├── transaction.js
├── sync.js
└── file.js
🛠️ Queue & Jobs
Sync Queue: Proses data dari client offline
Email Queue: Kirim notifikasi atau laporan
Backup Job: Backup data tenant secara berkala

Strategi untuk membangun sistem yang modular dan scalable dalam konteks SaaS POS seperti milikmu, cak, perlu menyentuh beberapa aspek inti: arsitektur kode, isolasi tenant, pengelolaan dependensi, dan fleksibilitas pengembangan fitur. Berikut strategi lengkapnya:

🧱 1. Modular Architecture
Tujuan: Memisahkan fitur agar mudah dikembangkan, diuji, dan di-scale.
🔹 Strategi:
Feature-based folder structure:
src/
├── modules/
│   ├── product/
│   │   ├── product.model.js
│   │   ├── product.service.js
│   │   ├── product.controller.js
│   │   └── product.routes.js
│   ├── transaction/
│   └── tenant/
Service Layer Abstraction: Pisahkan business logic dari controller.
Repository Pattern: Abstraksi akses DB agar mudah ganti ORM atau DB engine.
Middleware per modul: RBAC, validation, logging bisa modular.
🏢 2. Multi-Tenant Isolation
Tujuan: Menjamin data antar tenant tidak tercampur dan siap scale horizontal.
🔹 Strategi:
Tenant-aware models: Tambahkan tenant_id di semua tabel utama.
Global Sequelize Scope:

js
Product.addScope('byTenant', (tenantId) => ({
  where: { tenant_id: tenantId }
}));
JWT payload: Sertakan tenant_id dan role untuk filtering otomatis.

Database options:
Shared DB, shared schema (dengan tenant_id) → lebih efisien
Dedicated schema per tenant → lebih isolatif, cocok untuk enterprise

🚀 3. Scalability-Ready Components
Tujuan: Siap scale baik secara vertikal (fitur) maupun horizontal (jumlah tenant).

🔹 Strategi:
Queue System: Gunakan BullMQ atau Redis untuk job seperti sync, email, backup.
Rate Limiting & Caching: Redis untuk throttle dan cache data populer.
Stateless Services: Hindari menyimpan state di memory server.
Horizontal Scaling: Gunakan container (Docker) dan orchestrator (Kubernetes) jika traffic tinggi.

🔄 4. Sync Engine & Offline Strategy
Tujuan: Mendukung client offline dan sinkronisasi data yang robust.

🔹 Strategi:
UUID sebagai primary key: Hindari konflik antar client.

sync_source & updated_at: Untuk tracking perubahan dan resolusi konflik.

Conflict Resolver: Modular, bisa diganti per modul (product, transaction, dll).

Sync Queue: Proses sinkronisasi sebagai job async.

📦 5. File Storage Modular
Tujuan: File management yang scalable dan tenant-aware.

🔹 Strategi:
Multer + Custom Path Resolver: Simpan file sesuai struktur tenant.

Abstraction Layer: Buat service FileStorageService agar bisa ganti ke S3, Cloudinary, dll.

Metadata DB: Simpan info file (path, tenant, type) di DB untuk tracking.

contoh modul product yang modular, tenant-aware, dan siap scalable. Modul ini mencakup model, service, controller, dan route, serta integrasi dengan RBAC dan sync engine.

📦 Struktur Modul product
src/modules/product/
├── product.model.js         # Sequelize model
├── product.service.js       # Business logic
├── product.controller.js    # Route handler
├── product.routes.js        # Express router
├── product.validator.js     # Input validation (optional)
└── index.js                 # Modul entry (opsional untuk plugin-style)
🧬 product.model.js
js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/database');

const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  tenant_id: {
    type: DataTypes.STRING,
    allowNull: false
  },
  name: DataTypes.STRING,
  price: DataTypes.FLOAT,
  image_url: DataTypes.STRING,
  sync_source: DataTypes.STRING,
  updated_at: DataTypes.DATE
}, {
  timestamps: true,
  paranoid: true
});

Product.addScope('byTenant', (tenantId) => ({
  where: { tenant_id: tenantId }
}));

module.exports = Product;
🧠 product.service.js
js
const Product = require('./product.model');

async function createProduct(data, tenantId) {
  return await Product.create({ ...data, tenant_id: tenantId });
}

async function getProducts(tenantId) {
  return await Product.scope({ method: ['byTenant', tenantId] }).findAll();
}

async function updateProduct(id, data, tenantId) {
  const product = await Product.findOne({ where: { id, tenant_id: tenantId } });
  if (!product) throw new Error('Product not found');
  return await product.update(data);
}

module.exports = { createProduct, getProducts, updateProduct };
🎯 product.controller.js
js
const service = require('./product.service');

exports.create = async (req, res, next) => {
  try {
    const tenantId = req.user.tenant_id;
    const product = await service.createProduct(req.body, tenantId);
    res.status(201).json(product);
  } catch (err) {
    next(err);
  }
};

exports.list = async (req, res, next) => {
  try {
    const tenantId = req.user.tenant_id;
    const products = await service.getProducts(tenantId);
    res.json(products);
  } catch (err) {
    next(err);
  }
};
🚦 product.routes.js
js
const express = require('express');
const controller = require('./product.controller');
const auth = require('../../middleware/auth');
const rbac = require('../../middleware/rbac');

const router = express.Router();

router.use(auth.verifyToken); // JWT auth
router.use(rbac.allowRoles(['admin', 'kasir'])); // Role-based access

router.get('/', controller.list);
router.post('/', controller.create);

module.exports = router;
🔄 Integrasi Sync Engine (Opsional)
Di product.service.js, kamu bisa tambahkan:

js
// Saat create/update
data.sync_source = 'web';
data.updated_at = new Date();
Dan buat job di syncQueue.js untuk proses data dari client offline.

📁 Upload Gambar Produk (Opsional)
Tambahkan di product.controller.js:

js
const path = require('path');
const fs = require('fs');

exports.uploadImage = async (req, res) => {
  const tenantId = req.user.tenant_id;
  const filename = `product_${req.body.id}.jpg`;
  const uploadPath = path.join(__dirname, '../../uploads/tenants' + tenantId + '/products/', filename);

  fs.writeFileSync(uploadPath, req.file.buffer);
  res.json({ url: `/uploads/tenants${tenantId}/products/${filename}` });
};
Kalau kamu mau, kita bisa lanjut ke modul sync, transaction, atau bikin plugin-style loader agar modul bisa diaktifkan/dinonaktifkan sesuai kebutuhan tenant. Mau lanjut ke mana?

iya
Oke, cak! Kita lanjut ke modul sync, yang jadi jantung strategi offline-first kamu. Modul ini akan menangani data dari client offline, menyimpan perubahan, dan menyelesaikan konflik antar sumber data.

🔄 Modul sync — Offline-First Sync Engine
src/sync/
├── syncManager.js           # Entry point untuk sinkronisasi
├── conflictResolver.js      # Strategi resolusi konflik
├── syncQueue.js             # Job queue untuk proses async
└── sync.routes.js           # Endpoint untuk client offline
🧠 syncManager.js
js
const Product = require('../modules/product/product.model');
const resolveConflict = require('./conflictResolver');

async function syncData({ model, incomingData, tenantId }) {
  const existing = await model.findOne({ where: { id: incomingData.id, tenant_id: tenantId } });

  if (!existing) {
    return await model.create({ ...incomingData, tenant_id: tenantId });
  }

  const resolved = resolveConflict(existing, incomingData);
  return await existing.update(resolved);
}

module.exports = { syncData };
⚔️ conflictResolver.js
js
function resolveConflict(existing, incoming) {
  // Simple strategy: last-write-wins
  if (new Date(incoming.updated_at) > new Date(existing.updated_at)) {
    return { ...existing.toJSON(), ...incoming };
  }
  return existing.toJSON();
}

module.exports = resolveConflict;
Kamu bisa ganti strategi ini dengan merge, manual review, atau field-level resolution.

📬 syncQueue.js
js
const Queue = require('bullmq').Queue;
const { syncData } = require('./syncManager');
const Product = require('../modules/product/product.model');

const syncQueue = new Queue('sync');

syncQueue.process(async (job) => {
  const { data, modelName, tenantId } = job.data;
  const model = modelName === 'Product' ? Product : null; // Extendable

  if (model) {
    await syncData({ model, incomingData: data, tenantId });
  }
});

module.exports = syncQueue;
🌐 sync.routes.js
js
const express = require('express');
const syncQueue = require('./syncQueue');
const auth = require('../middleware/auth');

const router = express.Router();
router.use(auth.verifyToken);

router.post('/', async (req, res) => {
  const { modelName, data } = req.body;
  const tenantId = req.user.tenant_id;

  await syncQueue.add('sync', { modelName, data, tenantId });
  res.status(202).json({ message: 'Sync job queued' });
});

module.exports = router;
🧩 Integrasi ke App
Di app.js atau index.js:

js
const syncRoutes = require('./sync/sync.routes');
app.use('/api/sync', syncRoutes);
🔧 Tips Tambahan
Tambahkan sync_source di setiap data (mobile, web, sync)

Simpan log sinkronisasi per tenant untuk audit

Bisa tambahkan sync_token untuk versi data per client