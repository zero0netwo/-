-- ООО «СтройМатериалы»: схема базы данных для MySQL 8.0.16+
-- Скрипт создаёт базу, 11 таблиц и три роли.
-- Данные из Excel импортируются отдельно после проверки и исправления ошибок.

CREATE DATABASE IF NOT EXISTS stroymaterialy_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE stroymaterialy_db;

-- 1. Роли пользователей
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Категории товаров
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Производители
CREATE TABLE manufacturers (
    manufacturer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 4. Поставщики
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 5. Единицы измерения
CREATE TABLE units (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 6. Пункты выдачи
CREATE TABLE pickup_points (
    pickup_point_id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255) NOT NULL UNIQUE
);

-- 7. Статусы заказов
CREATE TABLE order_statuses (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 8. Пользователи
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    login VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,

    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 9. Товары
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    article VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    manufacturer_id INT NOT NULL,
    supplier_id INT NOT NULL,
    unit_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(5, 2) NOT NULL DEFAULT 0,
    stock_quantity INT NOT NULL DEFAULT 0,
    description TEXT NULL,
    image_path VARCHAR(255) NULL,

    CONSTRAINT chk_products_price CHECK (price >= 0),
    CONSTRAINT chk_products_discount CHECK (discount BETWEEN 0 AND 100),
    CONSTRAINT chk_products_stock CHECK (stock_quantity >= 0),

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_products_manufacturer
        FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_products_unit
        FOREIGN KEY (unit_id) REFERENCES units(unit_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 10. Заказы
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    pickup_point_id INT NOT NULL,
    status_id INT NOT NULL,
    order_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    receive_code VARCHAR(20) NOT NULL,

    CONSTRAINT fk_orders_client
        FOREIGN KEY (client_id) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_pickup_point
        FOREIGN KEY (pickup_point_id) REFERENCES pickup_points(pickup_point_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_status
        FOREIGN KEY (status_id) REFERENCES order_statuses(status_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 11. Состав заказов
CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,

    PRIMARY KEY (order_id, product_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Начальные роли (выполнить один раз)
INSERT INTO roles (name)
VALUES
    ('Клиент'),
    ('Менеджер'),
    ('Администратор');

-- Проверка
SHOW TABLES;
SELECT * FROM roles;
