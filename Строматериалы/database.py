import mysql.connector
import config


def connect_db():
    connection = mysql.connector.connect(
        host=config.DB_HOST,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME
    )

    return connection

def get_user(login, password):
    connection = connect_db()
    cursor = connection.cursor()

    try:
        query = """
            SELECT users.user_id, users.full_name, roles.name
            FROM users
            JOIN roles ON users.role_id = roles.role_id
            WHERE users.login = %s AND users.password = %s
        """

        cursor.execute(query, (login, password))
        user = cursor.fetchone()

        return user

    finally:
        cursor.close()
        connection.close()