-- ============================================================
--  DATABASE: petshop
--  Project : E-Commerce Pet Shop (PHP Native MVC)
--  API     : RajaOngkir
-- ============================================================

CREATE DATABASE IF NOT EXISTS petshop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE petshop;

-- ------------------------------------------------------------
-- 1. USERS
-- ------------------------------------------------------------
CREATE TABLE users (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100)        NOT NULL,
  email      VARCHAR(150)        NOT NULL UNIQUE,
  password   VARCHAR(255)        NOT NULL,
  role       ENUM('admin','user') NOT NULL DEFAULT 'user',
  phone      VARCHAR(20),
  created_at TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. CATEGORIES
-- ------------------------------------------------------------
CREATE TABLE categories (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  slug       VARCHAR(110) NOT NULL UNIQUE,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. PRODUCTS
-- ------------------------------------------------------------
CREATE TABLE products (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NOT NULL,
  name        VARCHAR(200) NOT NULL,
  slug        VARCHAR(210) NOT NULL UNIQUE,
  description TEXT,
  price       DECIMAL(12,2) NOT NULL DEFAULT 0,
  stock       INT UNSIGNED  NOT NULL DEFAULT 0,
  weight      INT UNSIGNED  NOT NULL DEFAULT 0 COMMENT 'dalam gram, untuk hitung ongkir',
  image       VARCHAR(255),
  is_active   TINYINT(1)    NOT NULL DEFAULT 1,
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_category FOREIGN KEY (category_id)
    REFERENCES categories(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. ADDRESSES  (alamat pengiriman milik user)
-- ------------------------------------------------------------
CREATE TABLE addresses (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id      INT UNSIGNED NOT NULL,
  label        VARCHAR(50)  NOT NULL DEFAULT 'Rumah' COMMENT 'Rumah / Kantor / dll',
  recipient    VARCHAR(100) NOT NULL,
  phone        VARCHAR(20)  NOT NULL,
  province_id  VARCHAR(10)  NOT NULL COMMENT 'dari API RajaOngkir',
  province     VARCHAR(100) NOT NULL,
  city_id      VARCHAR(10)  NOT NULL COMMENT 'dari API RajaOngkir',
  city         VARCHAR(100) NOT NULL,
  postal_code  VARCHAR(10),
  address      TEXT         NOT NULL,
  is_default   TINYINT(1)   NOT NULL DEFAULT 0,
  created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_address_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. CARTS
-- ------------------------------------------------------------
CREATE TABLE carts (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  qty        INT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_cart_item (user_id, product_id),
  CONSTRAINT fk_cart_user    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. ORDERS
-- ------------------------------------------------------------
CREATE TABLE orders (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED   NOT NULL,
  order_code      VARCHAR(30)    NOT NULL UNIQUE COMMENT 'contoh: ORD-20250601-0001',
  -- snapshot alamat (dicopy dari tabel addresses saat checkout)
  recipient       VARCHAR(100)   NOT NULL,
  phone           VARCHAR(20)    NOT NULL,
  province        VARCHAR(100)   NOT NULL,
  city            VARCHAR(100)   NOT NULL,
  address         TEXT           NOT NULL,
  postal_code     VARCHAR(10),
  -- ongkir
  courier         VARCHAR(30)    NOT NULL COMMENT 'jne / pos / tiki',
  courier_service VARCHAR(30)    NOT NULL COMMENT 'REG / YES / OKE',
  shipping_cost   DECIMAL(12,2)  NOT NULL DEFAULT 0,
  -- total
  subtotal        DECIMAL(12,2)  NOT NULL DEFAULT 0,
  total           DECIMAL(12,2)  NOT NULL DEFAULT 0 COMMENT 'subtotal + shipping_cost',
  -- status
  status          ENUM('pending','paid','processing','shipped','delivered','cancelled')
                  NOT NULL DEFAULT 'pending',
  note            TEXT,
  created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. ORDER DETAILS
-- ------------------------------------------------------------
CREATE TABLE order_details (
  id          INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  order_id    INT UNSIGNED  NOT NULL,
  product_id  INT UNSIGNED  NOT NULL,
  -- snapshot produk saat checkout (harga bisa berubah di masa depan)
  product_name VARCHAR(200) NOT NULL,
  price       DECIMAL(12,2) NOT NULL,
  qty         INT UNSIGNED  NOT NULL DEFAULT 1,
  subtotal    DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT 'price * qty',
  CONSTRAINT fk_detail_order   FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_detail_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
--  DATA DUMMY
-- ============================================================

-- Admin + 2 user (password: "password123" — bcrypt)
INSERT INTO users (name, email, password, role, phone) VALUES
  ('Admin Petshop', 'admin@petshop.com',
   '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '08110000001'),
  ('Budi Santoso',  'budi@gmail.com',
   '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user',  '08120000002'),
  ('Siti Rahayu',   'siti@gmail.com',
   '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user',  '08130000003');

-- Kategori produk pet shop
INSERT INTO categories (name, slug) VALUES
  ('Makanan Kucing',    'makanan-kucing'),
  ('Makanan Anjing',    'makanan-anjing'),
  ('Aksesoris Kucing',  'aksesoris-kucing'),
  ('Aksesoris Anjing',  'aksesoris-anjing'),
  ('Obat & Vitamin',    'obat-vitamin'),
  ('Kandang & Tempat Tidur', 'kandang-tempat-tidur');

-- Produk
INSERT INTO products (category_id, name, slug, description, price, stock, weight, image) VALUES
  (1, 'Whiskas Adult Tuna 1.2kg',      'whiskas-adult-tuna-12kg',
   'Makanan kucing dewasa rasa tuna, kaya protein dan omega-3.',
   65000, 50, 1200, 'whiskas-tuna.jpg'),

  (1, 'Royal Canin Indoor 2kg',         'royal-canin-indoor-2kg',
   'Formula khusus kucing yang tinggal di dalam ruangan.',
   185000, 30, 2000, 'royal-canin-indoor.jpg'),

  (2, 'Pedigree Beef & Vegetable 3kg',  'pedigree-beef-vegetable-3kg',
   'Makanan anjing dewasa rasa daging sapi dan sayuran.',
   120000, 40, 3000, 'pedigree-beef.jpg'),

  (3, 'Tempat Tidur Kucing Bulat',      'tempat-tidur-kucing-bulat',
   'Tempat tidur empuk berbentuk bulat dengan bahan fleece.',
   95000, 25, 800, 'cat-bed-round.jpg'),

  (4, 'Tali Leash Anjing 1.5m',         'tali-leash-anjing-15m',
   'Tali jalan anjing nylon kuat, panjang 1.5 meter.',
   45000, 60, 200, 'dog-leash.jpg'),

  (5, 'Vitamin Kucing Nutri-Tabs 100pcs','vitamin-kucing-nutri-tabs-100pcs',
   'Suplemen vitamin lengkap untuk kesehatan bulu dan imunitas kucing.',
   75000, 35, 150, 'nutri-tabs.jpg'),

  (6, 'Kandang Kucing Lipat 60x45cm',   'kandang-kucing-lipat-60x45cm',
   'Kandang besi lipat anti-karat, mudah dibawa dan disimpan.',
   320000, 15, 4500, 'cat-cage.jpg'),

  (2, 'Snack Anjing Bone Dental 200g',  'snack-anjing-bone-dental-200g',
   'Camilan tulang anjing untuk menjaga kesehatan gigi.',
   38000, 70, 200, 'dog-bone.jpg');

-- Alamat dummy untuk user Budi (user_id = 2)
INSERT INTO addresses (user_id, label, recipient, phone, province_id, province, city_id, city, postal_code, address, is_default)
VALUES
  (2, 'Rumah', 'Budi Santoso', '08120000002',
   '10', 'Jawa Tengah', '237', 'Kota Semarang', '50241',
   'Jl. Pemuda No. 15, Kel. Sekayu, Kec. Semarang Tengah', 1);