CREATE TABLE tenant (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  alamat TEXT,
  kontak_admin VARCHAR(100) NOT NULL UNIQUE,
  segmen ENUM('toko','niaga','grossir') NOT NULL,
  logo_path VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABEL: tenants
CREATE TABLE tenants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20) UNIQUE NOT NULL,
  tenant_name VARCHAR(100),
  owner_name VARCHAR(100),
  phone_number VARCHAR(20),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'active'
);

-- TABEL: plans
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

-- TABEL: subscriptions
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

-- TABEL: invoices
CREATE TABLE invoices (
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

-- TABEL: features
CREATE TABLE features (
  id INT AUTO_INCREMENT PRIMARY KEY,
  feature_code VARCHAR(20) UNIQUE NOT NULL,
  feature_name VARCHAR(100),
  price_monthly INT DEFAULT 0,
  price_yearly INT DEFAULT 0,
  price_onetime INT DEFAULT NULL,
  description TEXT
);

-- TABEL: tenant_features
CREATE TABLE tenant_features (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  feature_code VARCHAR(20),
  activated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) DEFAULT 'active',
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code),
  FOREIGN KEY (feature_code) REFERENCES features(feature_code)
);

-- TABEL: users
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  username VARCHAR(50),
  password_hash TEXT,
  role VARCHAR(20) DEFAULT 'staff',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- TABEL: permissions
CREATE TABLE permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role VARCHAR(20),
  module VARCHAR(50),
  can_view BOOLEAN DEFAULT TRUE,
  can_edit BOOLEAN DEFAULT FALSE,
  can_delete BOOLEAN DEFAULT FALSE
);

-- TABEL: devices
CREATE TABLE devices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  device_id VARCHAR(100),
  device_name VARCHAR(100),
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (tenant_code) REFERENCES tenants(tenant_code)
);

-- TABEL: device_logs
CREATE TABLE device_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  device_id VARCHAR(100),
  user_id INT,
  action VARCHAR(100),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- TABEL: activity_logs
CREATE TABLE activity_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  user_id INT,
  activity TEXT,
  module VARCHAR(50),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- TABEL: notifications
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_code VARCHAR(20),
  title VARCHAR(100),
  message TEXT,
  type VARCHAR(20),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);