buatkan struktur backend untuk project SaaS POS saya,
Arsitektur Umum
Struktur : Modular / Plugin-Style Loader
Framework: Node.js (Express.js)
Database: MySQL
ORM: Sequelize (Express) 
Auth: JWT + Role-based Access Control
Sync Engine: Offline-first dengan UUID dan sync_source tracking
Queue & Jobs: (sesuikan)
File Storage: untuk foto produk, logo tenant, doc dll

contoh struktur folder upload:
/uploads/
├── tenants{kode}/
│   ├── logo/
│   │   └── logo.png
│   └── products/
│   |    └── product_abc123.jpg
│   ├── doc/
│       └── template.xlm
├── vendor/
│   ├── logo/
│   │   └── logo1.jpg
│   └── doc/
│       └── mou.pdf
yang lain2 sesuiakan
