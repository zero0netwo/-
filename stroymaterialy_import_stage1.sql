-- Импорт данных демонстрационного экзамена для stroymaterialy_db
-- Запускать только после создания схемы из stroymaterialy_db.sql, на ПУСТЫХ таблицах (кроме roles).
-- Заказ №7 намеренно ПРОПУЩЕН: дата 30.02.2025 невозможна, артикул O43COU8 отсутствует.
-- После согласования обеих правок этот заказ добавим отдельным скриптом.
-- Очистка завершающих пробелов у имён справочников и статусов сделана осознанно.
-- Значение роли 'Авторизированный клиент' в Excel соответствует роли 'Клиент' в БД.
-- Пункты выдачи 1..36 сохраняют исходный порядок строк Excel (заголовка нет).
-- Для отсутствующих фото в image_path используется NULL (UI покажет picture.png).
-- Для 3XBOTN.jpg исправлено фактическое расширение файла: 3XBOTN.jpeg.
-- Пароли импортируются как в учебном источнике; для реального продукта нужно хеширование.

USE stroymaterialy_db;
START TRANSACTION;

-- Справочник: categories
INSERT INTO categories (name) VALUES
    ('Общестроительные материалы'),
    ('Стеновые и фасадные материалы'),
    ('Сухие строительные смеси и гидроизоляция'),
    ('Ручной инструмент'),
    ('Защита лица, глаз, головы');

-- Справочник: manufacturers
INSERT INTO manufacturers (name) VALUES
    ('М500'),
    ('Изостронг'),
    ('Knauf'),
    ('MixMaster'),
    ('ЛСР'),
    ('ВОЛМА'),
    ('Vinylon'),
    ('Павловский завод'),
    ('Weber'),
    ('Hesler'),
    ('Armero'),
    ('Wenzo Roma'),
    ('KILIMGRIN'),
    ('Исток'),
    ('RUIZ'),
    ('Husqvarna'),
    ('Delta');

-- Справочник: suppliers
INSERT INTO suppliers (name) VALUES
    ('М500'),
    ('Изостронг'),
    ('Knauf'),
    ('MixMaster'),
    ('ЛСР'),
    ('ВОЛМА'),
    ('Vinylon'),
    ('Павловский завод'),
    ('Weber'),
    ('Hesler'),
    ('Armero'),
    ('Wenzo Roma'),
    ('KILIMGRIN'),
    ('Исток'),
    ('RUIZ'),
    ('Husqvarna'),
    ('Delta');

-- Справочник: units
INSERT INTO units (name) VALUES
    ('шт.');

-- Справочник: order_statuses
INSERT INTO order_statuses (name) VALUES
    ('Завершен'),
    ('Новый');

-- Пункты выдачи (фиксируем исходные номера)
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
    (25, '614164, г.Лесной,  ул. Степная, 30'),
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

-- Пользователи
INSERT INTO users (role_id, full_name, login, password) VALUES
    ((SELECT role_id FROM roles WHERE name = 'Администратор'), 'Ворсин Петр Евгеньевич', '94d5ous@gmail.com', 'uzWC67'),
    ((SELECT role_id FROM roles WHERE name = 'Администратор'), 'Старикова Елена Павловна', 'uth4iz@mail.com', '2L6KZG'),
    ((SELECT role_id FROM roles WHERE name = 'Администратор'), 'Одинцов Серафим Артёмович', 'yzls62@outlook.com', 'JlFRCZ'),
    ((SELECT role_id FROM roles WHERE name = 'Менеджер'), 'Степанов Михаил Артёмович', '1diph5e@tutanota.com', '8ntwUp'),
    ((SELECT role_id FROM roles WHERE name = 'Менеджер'), 'Ворсин Петр Евгеньевич', 'tjde7c@yahoo.com', 'YOyhfR'),
    ((SELECT role_id FROM roles WHERE name = 'Менеджер'), 'Старикова Елена Павловна', 'wpmrc3do@tutanota.com', 'RSbvHv'),
    ((SELECT role_id FROM roles WHERE name = 'Клиент'), 'Михайлюк Анна Вячеславовна', '5d4zbu@tutanota.com', 'rwVDh9'),
    ((SELECT role_id FROM roles WHERE name = 'Клиент'), 'Ситдикова Елена Анатольевна', 'ptec8ym@yahoo.com', 'LdNyos'),
    ((SELECT role_id FROM roles WHERE name = 'Клиент'), 'Никифорова Весения Николаевна', '1qz4kw@mail.com', 'gynQMT'),
    ((SELECT role_id FROM roles WHERE name = 'Клиент'), 'Сазонов Руслан Германович', '4np6se@mail.com', 'AtnDjr');

-- Товары
INSERT INTO products (article, name, category_id, manufacturer_id, supplier_id, unit_id, price, discount, stock_quantity, description, image_path) VALUES
    ('PMEZMH', 'Цемент', (SELECT category_id FROM categories WHERE name = 'Общестроительные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'М500'), (SELECT supplier_id FROM suppliers WHERE name = 'М500'), (SELECT unit_id FROM units WHERE name = 'шт.'), 440, 8, 34, 'Цемент Евроцемент М500 Д0 ЦЕМ I 42,5 50 кг', 'resources/products/PMEZMH.jpg'),
    ('BPV4MM', 'Пленка техническая', (SELECT category_id FROM categories WHERE name = 'Общестроительные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Изостронг'), (SELECT supplier_id FROM suppliers WHERE name = 'Изостронг'), (SELECT unit_id FROM units WHERE name = 'шт.'), 8, 8, 2, 'Пленка техническая полиэтиленовая Изостронг 60 мк 3 м рукав 1,5 м, пог.м', 'resources/products/BPV4MM.jpg'),
    ('JVL42J', 'Пленка техническая', (SELECT category_id FROM categories WHERE name = 'Общестроительные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Изостронг'), (SELECT supplier_id FROM suppliers WHERE name = 'Изостронг'), (SELECT unit_id FROM units WHERE name = 'шт.'), 13, 4, 34, 'Пленка техническая полиэтиленовая Изостронг 100 мк 3 м рукав 1,5 м, пог.м', 'resources/products/JVL42J.jpg'),
    ('F895RB', 'Песок строительный', (SELECT category_id FROM categories WHERE name = 'Общестроительные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Knauf'), (SELECT supplier_id FROM suppliers WHERE name = 'Knauf'), (SELECT unit_id FROM units WHERE name = 'шт.'), 102, 6, 7, 'Песок строительный 50 кг', 'resources/products/F895RB.jpg'),
    ('3XBOTN', 'Керамзит фракция', (SELECT category_id FROM categories WHERE name = 'Общестроительные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'MixMaster'), (SELECT supplier_id FROM suppliers WHERE name = 'MixMaster'), (SELECT unit_id FROM units WHERE name = 'шт.'), 110, 5, 21, 'Керамзит фракция 10-20 мм 0,05 куб.м', 'resources/products/3XBOTN.jpeg'),
    ('3L7RCZ', 'Газобетон', (SELECT category_id FROM categories WHERE name = 'Стеновые и фасадные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'ЛСР'), (SELECT supplier_id FROM suppliers WHERE name = 'ЛСР'), (SELECT unit_id FROM units WHERE name = 'шт.'), 7400, 2, 20, 'Газобетон ЛСР 100х250х625 мм D400', 'resources/products/3L7RCZ.jpg'),
    ('S72AM3', 'Пазогребневая плита', (SELECT category_id FROM categories WHERE name = 'Стеновые и фасадные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'ВОЛМА'), (SELECT supplier_id FROM suppliers WHERE name = 'ВОЛМА'), (SELECT unit_id FROM units WHERE name = 'шт.'), 500, 5, 35, 'Пазогребневая плита ВОЛМА Гидро 667х500х80 мм полнотелая', 'resources/products/S72AM3.jpg'),
    ('2G3280', 'Угол наружный', (SELECT category_id FROM categories WHERE name = 'Стеновые и фасадные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Vinylon'), (SELECT supplier_id FROM suppliers WHERE name = 'Vinylon'), (SELECT unit_id FROM units WHERE name = 'шт.'), 795, 9, 20, 'Угол наружный Vinylon 3050 мм серо-голубой', 'resources/products/2G3280.jpg'),
    ('MIO8YV', 'Кирпич', (SELECT category_id FROM categories WHERE name = 'Стеновые и фасадные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'ВОЛМА'), (SELECT supplier_id FROM suppliers WHERE name = 'ВОЛМА'), (SELECT unit_id FROM units WHERE name = 'шт.'), 30, 9, 31, 'Кирпич рядовой Боровичи полнотелый М150 250х120х65 мм 1NF', 'resources/products/MIO8YV.jpg'),
    ('UER2QD', 'Скоба для пазогребневой плиты', (SELECT category_id FROM categories WHERE name = 'Стеновые и фасадные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Knauf'), (SELECT supplier_id FROM suppliers WHERE name = 'Knauf'), (SELECT unit_id FROM units WHERE name = 'шт.'), 25, 8, 27, 'Скоба для пазогребневой плиты Knauf С1 120х100 мм', 'resources/products/UER2QD.jpg'),
    ('ZR70B4', 'Кирпич', (SELECT category_id FROM categories WHERE name = 'Стеновые и фасадные материалы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Павловский завод'), (SELECT supplier_id FROM suppliers WHERE name = 'Павловский завод'), (SELECT unit_id FROM units WHERE name = 'шт.'), 16, 3, 0, 'Кирпич рядовой силикатный Павловский завод полнотелый М200 250х120х65 мм 1NF', NULL),
    ('LPDDM4', 'Штукатурка гипсовая', (SELECT category_id FROM categories WHERE name = 'Сухие строительные смеси и гидроизоляция'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Knauf'), (SELECT supplier_id FROM suppliers WHERE name = 'Knauf'), (SELECT unit_id FROM units WHERE name = 'шт.'), 500, 6, 38, 'Штукатурка гипсовая Knauf Ротбанд 30 кг', NULL),
    ('LQ48MW', 'Штукатурка гипсовая', (SELECT category_id FROM categories WHERE name = 'Сухие строительные смеси и гидроизоляция'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Weber'), (SELECT supplier_id FROM suppliers WHERE name = 'Weber'), (SELECT unit_id FROM units WHERE name = 'шт.'), 462, 6, 33, 'Штукатурка гипсовая Knauf МП-75 машинная 30 кг', NULL),
    ('O43COU', 'Шпаклевка', (SELECT category_id FROM categories WHERE name = 'Сухие строительные смеси и гидроизоляция'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'ВОЛМА'), (SELECT supplier_id FROM suppliers WHERE name = 'ВОЛМА'), (SELECT unit_id FROM units WHERE name = 'шт.'), 750, 1, 16, 'Шпаклевка полимерная Weber.vetonit LR + для сухих помещений белая 20 кг', NULL),
    ('M26EXW', 'Клей для плитки, керамогранита и камня', (SELECT category_id FROM categories WHERE name = 'Сухие строительные смеси и гидроизоляция'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Knauf'), (SELECT supplier_id FROM suppliers WHERE name = 'Knauf'), (SELECT unit_id FROM units WHERE name = 'шт.'), 340, 8, 0, 'Клей для плитки, керамогранита и камня Крепс Усиленный серый (класс С1) 25 кг', NULL),
    ('K0YACK', 'Смесь цементно-песчаная', (SELECT category_id FROM categories WHERE name = 'Сухие строительные смеси и гидроизоляция'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'MixMaster'), (SELECT supplier_id FROM suppliers WHERE name = 'MixMaster'), (SELECT unit_id FROM units WHERE name = 'шт.'), 160, 8, 19, 'Смесь цементно-песчаная (ЦПС) 300 по ТУ MixMaster Универсал 25 кг', NULL),
    ('ASPXSG', 'Ровнитель', (SELECT category_id FROM categories WHERE name = 'Сухие строительные смеси и гидроизоляция'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Weber'), (SELECT supplier_id FROM suppliers WHERE name = 'Weber'), (SELECT unit_id FROM units WHERE name = 'шт.'), 711, 10, 20, 'Ровнитель (наливной пол) финишный Weber.vetonit 4100 самовыравнивающийся высокопрочный 20 кг', NULL),
    ('ZKQ5FF', 'Лезвие для ножа', (SELECT category_id FROM categories WHERE name = 'Ручной инструмент'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Hesler'), (SELECT supplier_id FROM suppliers WHERE name = 'Hesler'), (SELECT unit_id FROM units WHERE name = 'шт.'), 65, 6, 6, 'Лезвие для ножа Hesler 18 мм прямое (10 шт.)', NULL),
    ('4WZEOT', 'Лезвие для ножа', (SELECT category_id FROM categories WHERE name = 'Ручной инструмент'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Armero'), (SELECT supplier_id FROM suppliers WHERE name = 'Armero'), (SELECT unit_id FROM units WHERE name = 'шт.'), 110, 6, 17, 'Лезвие для ножа Armero 18 мм прямое (10 шт.)', NULL),
    ('4JR1HN', 'Шпатель', (SELECT category_id FROM categories WHERE name = 'Ручной инструмент'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Hesler'), (SELECT supplier_id FROM suppliers WHERE name = 'Hesler'), (SELECT unit_id FROM units WHERE name = 'шт.'), 26, 6, 7, 'Шпатель малярный 100 мм с пластиковой ручкой', NULL),
    ('Z3XFSP', 'Нож строительный', (SELECT category_id FROM categories WHERE name = 'Ручной инструмент'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Hesler'), (SELECT supplier_id FROM suppliers WHERE name = 'Hesler'), (SELECT unit_id FROM units WHERE name = 'шт.'), 63, 8, 5, 'Нож строительный Hesler 18 мм с ломающимся лезвием пластиковый корпус', NULL),
    ('I6MH89', 'Валик', (SELECT category_id FROM categories WHERE name = 'Ручной инструмент'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Wenzo Roma'), (SELECT supplier_id FROM suppliers WHERE name = 'Wenzo Roma'), (SELECT unit_id FROM units WHERE name = 'шт.'), 326, 12, 3, 'Валик Wenzo Roma полиакрил 250 мм ворс 18 мм для красок грунтов и антисептиков на водной основе с рукояткой', NULL),
    ('83M5ME', 'Кисть', (SELECT category_id FROM categories WHERE name = 'Ручной инструмент'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Armero'), (SELECT supplier_id FROM suppliers WHERE name = 'Armero'), (SELECT unit_id FROM units WHERE name = 'шт.'), 122, 9, 26, 'Кисть плоская смешанная щетина 100х12 мм для красок и антисептиков на водной основе', NULL),
    ('61PGH3', 'Очки защитные', (SELECT category_id FROM categories WHERE name = 'Защита лица, глаз, головы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'KILIMGRIN'), (SELECT supplier_id FROM suppliers WHERE name = 'KILIMGRIN'), (SELECT unit_id FROM units WHERE name = 'шт.'), 184, 6, 25, 'Очки защитные Delta Plus KILIMANDJARO (KILIMGRIN) открытые с прозрачными линзами', NULL),
    ('GN6ICZ', 'Каска защитная', (SELECT category_id FROM categories WHERE name = 'Защита лица, глаз, головы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Исток'), (SELECT supplier_id FROM suppliers WHERE name = 'Исток'), (SELECT unit_id FROM units WHERE name = 'шт.'), 154, 15, 8, 'Каска защитная Исток (КАС001О) оранжевая', NULL),
    ('Z3LO0U', 'Очки защитные', (SELECT category_id FROM categories WHERE name = 'Защита лица, глаз, головы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'RUIZ'), (SELECT supplier_id FROM suppliers WHERE name = 'RUIZ'), (SELECT unit_id FROM units WHERE name = 'шт.'), 228, 9, 11, 'Очки защитные Delta Plus RUIZ (RUIZ1VI) закрытые с прозрачными линзами', NULL),
    ('QHNOKR', 'Маска защитная', (SELECT category_id FROM categories WHERE name = 'Защита лица, глаз, головы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Исток'), (SELECT supplier_id FROM suppliers WHERE name = 'Исток'), (SELECT unit_id FROM units WHERE name = 'шт.'), 251, 2, 22, 'Маска защитная Исток (ЩИТ001) ударопрочная и термостойкая', NULL),
    ('EQ6RKO', 'Подшлемник', (SELECT category_id FROM categories WHERE name = 'Защита лица, глаз, головы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Husqvarna'), (SELECT supplier_id FROM suppliers WHERE name = 'Husqvarna'), (SELECT unit_id FROM units WHERE name = 'шт.'), 36, 17, 22, 'Подшлемник для каски одноразовый', NULL),
    ('81F1WG', 'Каска защитная', (SELECT category_id FROM categories WHERE name = 'Защита лица, глаз, головы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Delta'), (SELECT supplier_id FROM suppliers WHERE name = 'Delta'), (SELECT unit_id FROM units WHERE name = 'шт.'), 1500, 2, 13, 'Каска защитная Delta Plus BASEBALL DIAMOND V UP (DIAM5UPBCFLBS) белая', NULL),
    ('0YGHZ7', 'Очки защитные', (SELECT category_id FROM categories WHERE name = 'Защита лица, глаз, головы'), (SELECT manufacturer_id FROM manufacturers WHERE name = 'Husqvarna'), (SELECT supplier_id FROM suppliers WHERE name = 'Husqvarna'), (SELECT unit_id FROM units WHERE name = 'шт.'), 700, 9, 36, 'Очки защитные Husqvarna Clear (5449638-01) открытые с прозрачными линзами', NULL);

-- Заказы (№7 пока не добавляем)
INSERT INTO orders (order_id, client_id, pickup_point_id, status_id, order_date, delivery_date, receive_code) VALUES
    (1, (SELECT user_id FROM users WHERE login = '5d4zbu@tutanota.com'), 1, (SELECT status_id FROM order_statuses WHERE name = 'Завершен'), '2025-02-27', '2025-04-20', '901'),
    (2, (SELECT user_id FROM users WHERE login = 'ptec8ym@yahoo.com'), 11, (SELECT status_id FROM order_statuses WHERE name = 'Завершен'), '2024-09-28', '2025-04-21', '902'),
    (3, (SELECT user_id FROM users WHERE login = '1qz4kw@mail.com'), 2, (SELECT status_id FROM order_statuses WHERE name = 'Завершен'), '2025-03-21', '2025-04-22', '903'),
    (4, (SELECT user_id FROM users WHERE login = '4np6se@mail.com'), 11, (SELECT status_id FROM order_statuses WHERE name = 'Завершен'), '2025-02-20', '2025-04-23', '904'),
    (5, (SELECT user_id FROM users WHERE login = '5d4zbu@tutanota.com'), 2, (SELECT status_id FROM order_statuses WHERE name = 'Завершен'), '2025-03-17', '2025-04-24', '905'),
    (6, (SELECT user_id FROM users WHERE login = 'ptec8ym@yahoo.com'), 15, (SELECT status_id FROM order_statuses WHERE name = 'Завершен'), '2025-03-01', '2025-04-25', '906'),
    (8, (SELECT user_id FROM users WHERE login = '4np6se@mail.com'), 19, (SELECT status_id FROM order_statuses WHERE name = 'Новый'), '2025-03-31', '2025-04-27', '908'),
    (9, (SELECT user_id FROM users WHERE login = '1qz4kw@mail.com'), 5, (SELECT status_id FROM order_statuses WHERE name = 'Новый'), '2025-04-02', '2025-04-28', '909'),
    (10, (SELECT user_id FROM users WHERE login = '4np6se@mail.com'), 19, (SELECT status_id FROM order_statuses WHERE name = 'Новый'), '2025-04-03', '2025-04-29', '910');

-- Состав заказов: один товар = одна строка
INSERT INTO order_items (order_id, product_id, quantity) VALUES
    (1, (SELECT product_id FROM products WHERE article = 'PMEZMH'), 2),
    (1, (SELECT product_id FROM products WHERE article = 'BPV4MM'), 2),
    (2, (SELECT product_id FROM products WHERE article = 'JVL42J'), 1),
    (2, (SELECT product_id FROM products WHERE article = 'F895RB'), 1),
    (3, (SELECT product_id FROM products WHERE article = '3XBOTN'), 10),
    (3, (SELECT product_id FROM products WHERE article = '3L7RCZ'), 10),
    (4, (SELECT product_id FROM products WHERE article = 'S72AM3'), 5),
    (4, (SELECT product_id FROM products WHERE article = '2G3280'), 4),
    (5, (SELECT product_id FROM products WHERE article = 'MIO8YV'), 2),
    (5, (SELECT product_id FROM products WHERE article = 'UER2QD'), 2),
    (6, (SELECT product_id FROM products WHERE article = 'ZR70B4'), 1),
    (6, (SELECT product_id FROM products WHERE article = 'LPDDM4'), 1),
    (8, (SELECT product_id FROM products WHERE article = 'M26EXW'), 5),
    (8, (SELECT product_id FROM products WHERE article = 'K0YACK'), 4),
    (9, (SELECT product_id FROM products WHERE article = 'ASPXSG'), 5),
    (9, (SELECT product_id FROM products WHERE article = 'ZKQ5FF'), 1),
    (10, (SELECT product_id FROM products WHERE article = '4WZEOT'), 5),
    (10, (SELECT product_id FROM products WHERE article = '4JR1HN'), 5);

COMMIT;

-- Контрольное количество строк. До загрузки заказа №7: 9 заказов и 18 позиций.
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
