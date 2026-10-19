import tkinter as tk
from tkinter import messagebox
import mysql.connector
from auth import authenticate_user


def open_login_window(root):
    title = tk.Label(
        root,
        text="Авторизация",
        font=("Calibri", 18)
    )
    title.pack(pady=20)

    login_label = tk.Label(root, text="Логин")
    login_label.pack()

    login_entry = tk.Entry(root)
    login_entry.pack(pady=5)

    password_label = tk.Label(root, text="Пароль")
    password_label.pack()

    password_entry = tk.Entry(root, show="*")
    password_entry.pack(pady=5)

    def login():
        username = login_entry.get().strip()
        password = password_entry.get()

        if not username or not password:
            messagebox.showwarning(
                "Ошибка",
                "Введите логин и пароль"
            )
            return

        try:
            user = authenticate_user(username, password)

        except mysql.connector.Error as error:
            messagebox.showerror(
                "Ошибка подключения",
                f"Не удалось выполнить запрос к базе данных:\n{error}"
            )
            return

        if user is None:
            messagebox.showerror(
                "Ошибка авторизации",
                "Неверный логин или пароль"
            )
            return

        messagebox.showinfo(
            "Успешный вход",
            f"Здравствуйте, {user[1]}!\nВаша роль: {user[2]}"
        )

    login_button = tk.Button(root, text="Войти")
    login_button.pack(pady=10)

    guest_button = tk.Button(root, text="Войти как гость")
    guest_button.pack()