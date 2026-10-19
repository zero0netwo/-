-- ПОЛНЫЙ СКРИПТ ООО «СтройМатериалы» (вариант №3, ДЭ 2026)
-- Требуется MySQL 8.0.16 или новее.
-- ВНИМАНИЕ: УДАЛЯЕТ целиком БД stroymaterialy_db (если она существует),
-- включая все ранее созданные в ней таблицы и записи.
-- ДРУГИЕ базы данных этот скрипт не изменяет.
-- 11 таблиц, 30 товаров, 10 пользователей, 10 заказов, 20 позиций, 36 адресов.
--
-- ОТКЛОНЕНИЯ В ПРЕДОСТАВЛЕННОМ EXCEL, ТРЕБУЮЩИЕ УТОЧНЕНИЯ:
-- 1) Заказ 7: исходная дата заказа «30.02.2025» невозможна.
--    Чтобы сохранить заказ и НЕ ВЫДУМЫВАТЬ дату, order_date допускает NULL,
--    а у заказа 7 временно установлено NULL до уточнения корректной даты.
-- 2) Заказ 7: артикул «O43COU8» отсутствует в каталоге; имеется «O43COU».
--    В составе заказа 7 используется предполагаемое исправление O43COU.
--    Этот выбор НЕ подтверждён источником, проверьте его перед сдачей.
-- 3) Фото 3XBOTN: в Excel .jpg, физически в ресурсах .jpeg.
-- 4) Пробелы в конце некоторых исходных строк нормализованы.
-- 5) Учебные пароли импортированы как в исходном файле (не для продакшена).
-- 6) Папка ресурсов с фото должна быть размещена отдельно по путям image_path.

DROP DATABASE IF EXISTS stroymaterialy_db;

CREATE DATABASE stroymaterialy_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE stroymaterialy_db;

-- Справочники
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE manufacturers (
    manufacturer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE units (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE pickup_points (
    pickup_point_id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE order_statuses (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Пользователи
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    login VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Товары: строковый article сохраняется, product_id числовой.
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    article VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    manufacturer_id INT NOT NULL,
    supplier_id INT NOT NULL,
    unit_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(5,2) NOT NULL DEFAULT 0,
    stock_quantity INT NOT NULL DEFAULT 0,
    description TEXT NULL,
    image_path VARCHAR(255) NULL,
    CONSTRAINT chk_products_price CHECK (price >= 0),
    CONSTRAINT chk_products_discount CHECK (discount BETWEEN 0 AND 100),
    CONSTRAINT chk_products_stock CHECK (stock_quantity >= 0),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_products_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_products_unit FOREIGN KEY (unit_id) REFERENCES units(unit_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Заказы: дата заказа допускает NULL только из-за ошибочного исходного значения заказа 7.
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    pickup_point_id INT NOT NULL,
    status_id INT NOT NULL,
    order_date DATE NULL,
    delivery_date DATE NOT NULL,
    receive_code VARCHAR(20) NOT NULL,
    CONSTRAINT fk_orders_client FOREIGN KEY (client_id) REFERENCES users(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orders_pickup_point FOREIGN KEY (pickup_point_id) REFERENCES pickup_points(pickup_point_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orders_status FOREIGN KEY (status_id) REFERENCES order_statuses(status_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Состав заказов: одна строка на один товар в заказе
CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Все данные из Excel загружаем единой транзакцией.
START TRANSACTION;

-- Роли
INSERT INTO roles (role_id, name) VALUES
    (1, 'Клиент'),
    (2, 'Менеджер'),
    (3, 'Администратор');

-- Категории
INSERT INTO categories (category_id, name) VALUES
    (1, 'Общестроительные материалы'),
    (2, 'Стеновые и фасадные материалы'),
    (3, 'Сухие строительные смеси и гидроизоляция'),
    (4, 'Ручной инструмент'),
    (5, 'Защита лица, глаз, головы');

-- Производители
INSERT INTO manufacturers (manufacturer_id, name) VALUES
    (1, 'М500'),
    (2, 'Изостронг'),
    (3, 'Knauf'),
    (4, 'MixMaster'),
    (5, 'ЛСР'),
    (6, 'ВОЛМА'),
    (7, 'Vinylon'),
    (8, 'Павловский завод'),
    (9, 'Weber'),
    (10, 'Hesler'),
    (11, 'Armero'),
    (12, 'Wenzo Roma'),
    (13, 'KILIMGRIN'),
    (14, 'Исток'),
    (15, 'RUIZ'),
    (16, 'Husqvarna'),
    (17, 'Delta');

-- Поставщики
INSERT INTO suppliers (supplier_id, name) VALUES
    (1, 'М500'),
    (2, 'Изостронг'),
    (3, 'Knauf'),
    (4, 'MixMaster'),
    (5, 'ЛСР'),
    (6, 'ВОЛМА'),
    (7, 'Vinylon'),
    (8, 'Павловский завод'),
    (9, 'Weber'),
    (10, 'Hesler'),
    (11, 'Armero'),
    (12, 'Wenzo Roma'),
    (13, 'KILIMGRIN'),
    (14, 'Исток'),
    (15, 'RUIZ'),
    (16, 'Husqvarna'),
    (17, 'Delta');

-- Единицы измерения
INSERT INTO units (unit_id, name) VALUES
    (1, 'шт.');

-- Статусы заказов
INSERT INTO order_statuses (status_id, name) VALUES
    (1, 'Завершен'),
    (2, 'Новый');

-- 36 пунктов выдачи (ID соответствуют исходному порядку строк Excel)
INSERT INTO pickup_points (pickup_point_id, address) VALUES
    (1, '420151, г. Лесной, ул. Вишневая, 32'),
    (2, '125061, г. Лесной, ул. Подгорная, 8'),
    (3, '630370, г. Лесной, ул. Шоссейная, 24'),
    (4, '400562, г. Лесной, ул. Зеленая, 32'),
    (5, '614510, г. Лесной, ул. Маяковского, 47'),
    (6, '410542, г. Лесной, ул. Светлая, 46'),
    (7, '620839, г. Лесной, ул. Цветочная, 8'),
    (8, '443890, г. Лесной, ул. Коммунистическая, 1'),
    (9, '603379, г. Лесной, ул. Спортивная, 46'),
    (10, '603721, г. Лесной, ул. Гоголя, 41'),
    (11, '410172, г. Лесной, ул. Северная, 13'),
    (12, '614611, г. Лесной, ул. Молодежная, 50'),
    (13, '454311, г.Лесной, ул. Новая, 19'),
    (14, '660007, г.Лесной, ул. Октябрьская, 19'),
    (15, '603036, г. Лесной, ул. Садовая, 4'),
    (16, '394060, г.Лесной, ул. Фрунзе, 43'),
    (17, '410661, г. Лесной, ул. Школьная, 50'),
    (18, '625590, г. Лесной, ул. Коммунистическая, 20'),
    (19, '625683, г. Лесной, ул. 8 Марта'),
    (20, '450983, г.Лесной, ул. Комсомольская, 26'),
    (21, '394782, г. Лесной, ул. Чехова, 3'),
    (22, '603002, г. Лесной, ул. Дзержинского, 28'),
    (23, '450558, г. Лесной, ул. Набережная, 30'),
    (24, '344288, г. Лесной, ул. Чехова, 1'),
    (25, '614164, г.Лесной,  ул. Степная, 30'),
    (26, '394242, г. Лесной, ул. Коммунистическая, 43'),
    (27, '660540, г. Лесной, ул. Солнечная, 25'),
    (28, '125837, г. Лесной, ул. Шоссейная, 40'),
    (29, '125703, г. Лесной, ул. Партизанская, 49'),
    (30, '625283, г. Лесной, ул. Победы, 46'),
    (31, '614753, г. Лесной, ул. Полевая, 35'),
    (32, '426030, г. Лесной, ул. Маяковского, 44'),
    (33, '450375, г. Лесной ул. Клубная, 44'),
    (34, '625560, г. Лесной, ул. Некрасова, 12'),
    (35, '630201, г. Лесной, ул. Комсомольская, 17'),
    (36, '190949, г. Лесной, ул. Мичурина, 26');

-- 10 пользователей (пароли учебные из исходного файла)
INSERT INTO users (user_id, role_id, full_name, login, password) VALUES
    (1, 3, 'Ворсин Петр Евгеньевич', '94d5ous@gmail.com', 'uzWC67'),
    (2, 3, 'Старикова Елена Павловна', 'uth4iz@mail.com', '2L6KZG'),
    (3, 3, 'Одинцов Серафим Артёмович', 'yzls62@outlook.com', 'JlFRCZ'),
    (4, 2, 'Степанов Михаил Артёмович', '1diph5e@tutanota.com', '8ntwUp'),
    (5, 2, 'Ворсин Петр Евгеньевич', 'tjde7c@yahoo.com', 'YOyhfR'),
    (6, 2, 'Старикова Елена Павловна', 'wpmrc3do@tutanota.com', 'RSbvHv'),
    (7, 1, 'Михайлюк Анна Вячеславовна', '5d4zbu@tutanota.com', 'rwVDh9'),
    (8, 1, 'Ситдикова Елена Анатольевна', 'ptec8ym@yahoo.com', 'LdNyos'),
    (9, 1, 'Никифорова Весения Николаевна', '1qz4kw@mail.com', 'gynQMT'),
    (10, 1, 'Сазонов Руслан Германович', '4np6se@mail.com', 'AtnDjr');

-- 30 товаров; у 10 есть фото, остальные image_path = NULL
INSERT INTO products (product_id, article, name, category_id, manufacturer_id, supplier_id, unit_id, price, discount, stock_quantity, description, image_path) VALUES
    (1, 'PMEZMH', 'Цемент', 1, 1, 1, 1, 440, 8, 34, 'Цемент Евроцемент М500 Д0 ЦЕМ I 42,5 50 кг', 'resources/products/PMEZMH.jpg'),
    (2, 'BPV4MM', 'Пленка техническая', 1, 2, 2, 1, 8, 8, 2, 'Пленка техническая полиэтиленовая Изостронг 60 мк 3 м рукав 1,5 м, пог.м', 'resources/products/BPV4MM.jpg'),
    (3, 'JVL42J', 'Пленка техническая', 1, 2, 2, 1, 13, 4, 34, 'Пленка техническая полиэтиленовая Изостронг 100 мк 3 м рукав 1,5 м, пог.м', 'resources/products/JVL42J.jpg'),
    (4, 'F895RB', 'Песок строительный', 1, 3, 3, 1, 102, 6, 7, 'Песок строительный 50 кг', 'resources/products/F895RB.jpg'),
    (5, '3XBOTN', 'Керамзит фракция', 1, 4, 4, 1, 110, 5, 21, 'Керамзит фракция 10-20 мм 0,05 куб.м', 'resources/products/3XBOTN.jpeg'),
    (6, '3L7RCZ', 'Газобетон', 2, 5, 5, 1, 7400, 2, 20, 'Газобетон ЛСР 100х250х625 мм D400', 'resources/products/3L7RCZ.jpg'),
    (7, 'S72AM3', 'Пазогребневая плита', 2, 6, 6, 1, 500, 5, 35, 'Пазогребневая плита ВОЛМА Гидро 667х500х80 мм полнотелая', 'resources/products/S72AM3.jpg'),
    (8, '2G3280', 'Угол наружный', 2, 7, 7, 1, 795, 9, 20, 'Угол наружный Vinylon 3050 мм серо-голубой', 'resources/products/2G3280.jpg'),
    (9, 'MIO8YV', 'Кирпич', 2, 6, 6, 1, 30, 9, 31, 'Кирпич рядовой Боровичи полнотелый М150 250х120х65 мм 1NF', 'resources/products/MIO8YV.jpg'),
    (10, 'UER2QD', 'Скоба для пазогребневой плиты', 2, 3, 3, 1, 25, 8, 27, 'Скоба для пазогребневой плиты Knauf С1 120х100 мм', 'resources/products/UER2QD.jpg'),
    (11, 'ZR70B4', 'Кирпич', 2, 8, 8, 1, 16, 3, 0, 'Кирпич рядовой силикатный Павловский завод полнотелый М200 250х120х65 мм 1NF', NULL),
    (12, 'LPDDM4', 'Штукатурка гипсовая', 3, 3, 3, 1, 500, 6, 38, 'Штукатурка гипсовая Knauf Ротбанд 30 кг', NULL),
    (13, 'LQ48MW', 'Штукатурка гипсовая', 3, 9, 9, 1, 462, 6, 33, 'Штукатурка гипсовая Knauf МП-75 машинная 30 кг', NULL),
    (14, 'O43COU', 'Шпаклевка', 3, 6, 6, 1, 750, 1, 16, 'Шпаклевка полимерная Weber.vetonit LR + для сухих помещений белая 20 кг', NULL),
    (15, 'M26EXW', 'Клей для плитки, керамогранита и камня', 3, 3, 3, 1, 340, 8, 0, 'Клей для плитки, керамогранита и камня Крепс Усиленный серый (класс С1) 25 кг', NULL),
    (16, 'K0YACK', 'Смесь цементно-песчаная', 3, 4, 4, 1, 160, 8, 19, 'Смесь цементно-песчаная (ЦПС) 300 по ТУ MixMaster Универсал 25 кг', NULL),
    (17, 'ASPXSG', 'Ровнитель', 3, 9, 9, 1, 711, 10, 20, 'Ровнитель (наливной пол) финишный Weber.vetonit 4100 самовыравнивающийся высокопрочный 20 кг', NULL),
    (18, 'ZKQ5FF', 'Лезвие для ножа', 4, 10, 10, 1, 65, 6, 6, 'Лезвие для ножа Hesler 18 мм прямое (10 шт.)', NULL),
    (19, '4WZEOT', 'Лезвие для ножа', 4, 11, 11, 1, 110, 6, 17, 'Лезвие для ножа Armero 18 мм прямое (10 шт.)', NULL),
    (20, '4JR1HN', 'Шпатель', 4, 10, 10, 1, 26, 6, 7, 'Шпатель малярный 100 мм с пластиковой ручкой', NULL),
    (21, 'Z3XFSP', 'Нож строительный', 4, 10, 10, 1, 63, 8, 5, 'Нож строительный Hesler 18 мм с ломающимся лезвием пластиковый корпус', NULL),
    (22, 'I6MH89', 'Валик', 4, 12, 12, 1, 326, 12, 3, 'Валик Wenzo Roma полиакрил 250 мм ворс 18 мм для красок грунтов и антисептиков на водной основе с рукояткой', NULL),
    (23, '83M5ME', 'Кисть', 4, 11, 11, 1, 122, 9, 26, 'Кисть плоская смешанная щетина 100х12 мм для красок и антисептиков на водной основе', NULL),
    (24, '61PGH3', 'Очки защитные', 5, 13, 13, 1, 184, 6, 25, 'Очки защитные Delta Plus KILIMANDJARO (KILIMGRIN) открытые с прозрачными линзами', NULL),
    (25, 'GN6ICZ', 'Каска защитная', 5, 14, 14, 1, 154, 15, 8, 'Каска защитная Исток (КАС001О) оранжевая', NULL),
    (26, 'Z3LO0U', 'Очки защитные', 5, 15, 15, 1, 228, 9, 11, 'Очки защитные Delta Plus RUIZ (RUIZ1VI) закрытые с прозрачными линзами', NULL),
    (27, 'QHNOKR', 'Маска защитная', 5, 14, 14, 1, 251, 2, 22, 'Маска защитная Исток (ЩИТ001) ударопрочная и термостойкая', NULL),
    (28, 'EQ6RKO', 'Подшлемник', 5, 16, 16, 1, 36, 17, 22, 'Подшлемник для каски одноразовый', NULL),
    (29, '81F1WG', 'Каска защитная', 5, 17, 17, 1, 1500, 2, 13, 'Каска защитная Delta Plus BASEBALL DIAMOND V UP (DIAM5UPBCFLBS) белая', NULL),
    (30, '0YGHZ7', 'Очки защитные', 5, 16, 16, 1, 700, 9, 36, 'Очки защитные Husqvarna Clear (5449638-01) открытые с прозрачными линзами', NULL);

-- 10 заказов; у заказа 7 order_date = NULL вместо невозможного 30.02.2025
INSERT INTO orders (order_id, client_id, pickup_point_id, status_id, order_date, delivery_date, receive_code) VALUES
    (1, 7, 1, 1, '2025-02-27', '2025-04-20', '901'),
    (2, 8, 11, 1, '2024-09-28', '2025-04-21', '902'),
    (3, 9, 2, 1, '2025-03-21', '2025-04-22', '903'),
    (4, 10, 11, 1, '2025-02-20', '2025-04-23', '904'),
    (5, 7, 2, 1, '2025-03-17', '2025-04-24', '905'),
    (6, 8, 15, 1, '2025-03-01', '2025-04-25', '906'),
    (7, 9, 3, 1, NULL, '2025-04-26', '907'),
    (8, 10, 19, 2, '2025-03-31', '2025-04-27', '908'),
    (9, 9, 5, 2, '2025-04-02', '2025-04-28', '909'),
    (10, 10, 19, 2, '2025-04-03', '2025-04-29', '910');

-- 20 строк состава заказов; O43COU8 -> O43COU у заказа 7 (предполагаемая опечатка)
INSERT INTO order_items (order_id, product_id, quantity) VALUES
    (1, 1, 2),
    (1, 2, 2),
    (2, 3, 1),
    (2, 4, 1),
    (3, 5, 10),
    (3, 6, 10),
    (4, 7, 5),
    (4, 8, 4),
    (5, 9, 2),
    (5, 10, 2),
    (6, 11, 1),
    (6, 12, 1),
    (7, 13, 10),
    (7, 14, 10),
    (8, 15, 5),
    (8, 16, 4),
    (9, 17, 5),
    (9, 18, 1),
    (10, 19, 5),
    (10, 20, 5);

COMMIT;

-- Контрольные количества строк
SELECT 'roles' AS table_name, COUNT(*) AS row_count FROM roles
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'manufacturers', COUNT(*) FROM manufacturers
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'units', COUNT(*) FROM units
UNION ALL SELECT 'pickup_points', COUNT(*) FROM pickup_points
UNION ALL SELECT 'order_statuses', COUNT(*) FROM order_statuses
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

-- Убедиться, что все 10 заказов загрузились; у заказа 7 дата пока неизвестна.
SELECT order_id, order_date, delivery_date, receive_code
FROM orders
ORDER BY order_id;

-- После согласования даты заказа 7 заменить NULL настоящим значением:
-- UPDATE orders SET order_date = 'YYYY-MM-DD' WHERE order_id = 7;
-- Затем при необходимости вернуть ограничение NOT NULL для order_date.
-- ALTER TABLE orders MODIFY order_date DATE NOT NULL;

-- Новые товарные артикулы (PRD31, PRD32, ...) позже генерирует приложение Python.
