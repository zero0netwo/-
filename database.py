import mysql.connector
from config import DB_CONFIG


def connection():
    return mysql.connector.connect(**DB_CONFIG)


def get_user(email, password):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        query = """
            SELECT u.user_id, u.full_name, u.login, r.name
            FROM users AS u
            JOIN roles AS r ON u.role_id = r.role_id
            WHERE u.login = %s AND u.password = %s
        """
        cursor.execute(query, (email, password))
        return cursor.fetchone()
    finally:
        cursor.close()
        connect_db.close()


def get_products():
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        query = """
            SELECT
                p.product_id, p.article, p.name AS product_name,
                p.price, p.discount, p.stock_quantity, p.image_path,
                p.category_id, p.manufacturer_id, p.supplier_id,
                p.unit_id, p.description,
                c.name AS category_name, m.name AS manufacturer_name,
                s.name AS supplier_name, u.name AS unit_name
            FROM products AS p
            JOIN categories AS c ON p.category_id = c.category_id
            JOIN manufacturers AS m ON p.manufacturer_id = m.manufacturer_id
            JOIN suppliers AS s ON p.supplier_id = s.supplier_id
            JOIN units AS u ON p.unit_id = u.unit_id
            ORDER BY p.product_id DESC
        """
        cursor.execute(query)
        return cursor.fetchall()
    finally:
        cursor.close()
        connect_db.close()


def get_product(product_id):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute("""
            SELECT product_id, article, name, price, discount,
                   stock_quantity, image_path, category_id,
                   manufacturer_id, supplier_id, unit_id, description
            FROM products WHERE product_id = %s
        """, (product_id,))
        return cursor.fetchone()
    finally:
        cursor.close()
        connect_db.close()


def get_reference(table_name):
    tables = {
        'categories': ('category_id', 'name'),
        'manufacturers': ('manufacturer_id', 'name'),
        'suppliers': ('supplier_id', 'name'),
        'units': ('unit_id', 'name'),
        'pickup_points': ('pickup_point_id', 'address'),
        'order_statuses': ('status_id', 'name'),
        'users': ('user_id', 'full_name')
    }
    if table_name not in tables:
        raise ValueError('Неизвестный справочник: ' + table_name)

    id_col, text_col = tables[table_name]
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        query = f'SELECT {id_col}, {text_col} FROM {table_name}'
        if table_name == 'users':
            query += " WHERE role_id = (SELECT role_id FROM roles WHERE name = 'Клиент' LIMIT 1)"
        query += f' ORDER BY {text_col}'
        cursor.execute(query)
        return cursor.fetchall()
    finally:
        cursor.close()
        connect_db.close()


def add_product(values):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute("""
            INSERT INTO products
                (article, name, category_id, manufacturer_id, supplier_id,
                 unit_id, price, discount, stock_quantity, description, image_path)
            VALUES (CONCAT('TMP_', UUID()), %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, values)
        product_id = cursor.lastrowid
        cursor.execute('UPDATE products SET article = %s WHERE product_id = %s',
                       (f'PRD{product_id}', product_id))
        connect_db.commit()
        return product_id
    except Exception:
        connect_db.rollback()
        raise
    finally:
        cursor.close()
        connect_db.close()


def update_product(product_id, values):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute("""
            UPDATE products
            SET name = %s, category_id = %s, manufacturer_id = %s,
                supplier_id = %s, unit_id = %s, price = %s,
                discount = %s, stock_quantity = %s, description = %s,
                image_path = %s
            WHERE product_id = %s
        """, (*values, product_id))
        if cursor.rowcount == 0:
            cursor.execute('SELECT product_id FROM products WHERE product_id = %s', (product_id,))
            if cursor.fetchone() is None:
                raise ValueError('Товар не найден')
        connect_db.commit()
    except Exception:
        connect_db.rollback()
        raise
    finally:
        cursor.close()
        connect_db.close()


def delete_product(product_id):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute('SELECT COUNT(*) FROM order_items WHERE product_id = %s', (product_id,))
        if cursor.fetchone()[0] > 0:
            raise ValueError('Удаление запрещено: этот товар входит в один или несколько заказов.')
        cursor.execute('DELETE FROM products WHERE product_id = %s', (product_id,))
        if cursor.rowcount == 0:
            raise ValueError('Товар не найден')
        connect_db.commit()
    except Exception:
        connect_db.rollback()
        raise
    finally:
        cursor.close()
        connect_db.close()


def image_in_use(image_path):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute('SELECT COUNT(*) FROM products WHERE image_path = %s', (image_path,))
        return cursor.fetchone()[0] > 0
    finally:
        cursor.close()
        connect_db.close()


def get_orders():
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute("""
            SELECT o.order_id,
                   COALESCE(GROUP_CONCAT(CONCAT(p.article, ' × ', oi.quantity)
                                         ORDER BY p.article SEPARATOR ', '), '') AS products,
                   st.name, pp.address, o.order_date, o.delivery_date,
                   us.full_name, o.receive_code
            FROM orders AS o
            JOIN users AS us ON o.client_id = us.user_id
            JOIN pickup_points AS pp ON o.pickup_point_id = pp.pickup_point_id
            JOIN order_statuses AS st ON o.status_id = st.status_id
            LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
            LEFT JOIN products AS p ON p.product_id = oi.product_id
            GROUP BY o.order_id, st.name, pp.address, o.order_date,
                     o.delivery_date, us.full_name, o.receive_code
            ORDER BY o.order_id DESC
        """)
        return cursor.fetchall()
    finally:
        cursor.close()
        connect_db.close()


def get_order(order_id):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute("""
            SELECT order_id, client_id, pickup_point_id, status_id,
                   order_date, delivery_date, receive_code
            FROM orders WHERE order_id = %s
        """, (order_id,))
        return cursor.fetchone()
    finally:
        cursor.close()
        connect_db.close()


def get_order_items(order_id):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute("""
            SELECT product_id, quantity FROM order_items WHERE order_id = %s
        """, (order_id,))
        return cursor.fetchall()
    finally:
        cursor.close()
        connect_db.close()


def get_product_choices():
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute('SELECT product_id, article, name FROM products ORDER BY name, article')
        return cursor.fetchall()
    finally:
        cursor.close()
        connect_db.close()


def save_order(order_id, values, items):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        if order_id is None:
            cursor.execute("""
                INSERT INTO orders (client_id, pickup_point_id, status_id,
                                    order_date, delivery_date, receive_code)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, values)
            order_id = cursor.lastrowid
        else:
            cursor.execute("""
                UPDATE orders
                SET client_id = %s, pickup_point_id = %s, status_id = %s,
                    order_date = %s, delivery_date = %s, receive_code = %s
                WHERE order_id = %s
            """, (*values, order_id))
            cursor.execute('DELETE FROM order_items WHERE order_id = %s', (order_id,))

        for product_id, quantity in items:
            cursor.execute("""
                INSERT INTO order_items (order_id, product_id, quantity)
                VALUES (%s, %s, %s)
            """, (order_id, product_id, quantity))
        connect_db.commit()
        return order_id
    except Exception:
        connect_db.rollback()
        raise
    finally:
        cursor.close()
        connect_db.close()


def delete_order(order_id):
    connect_db = connection()
    cursor = connect_db.cursor()
    try:
        cursor.execute('DELETE FROM orders WHERE order_id = %s', (order_id,))
        if cursor.rowcount == 0:
            raise ValueError('Заказ не найден')
        connect_db.commit()
    except Exception:
        connect_db.rollback()
        raise
    finally:
        cursor.close()
        connect_db.close()
