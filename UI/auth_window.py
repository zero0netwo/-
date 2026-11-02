from tkinter import *
from tkinter import messagebox
from database import get_user
from UI.main_window import open_main_window


def open_root(root):
    login_text = Label(root, text='Логин')
    login_text.grid(row=0, column=0, padx=10, pady=10)
    password_text = Label(root, text='Пароль')
    password_text.grid(row=1, column=0, padx=10, pady=10)
    login_field = Entry(root, width=36)
    login_field.grid(row=0, column=1, padx=10, pady=10)
    password_field = Entry(root, width=36, show='*')
    password_field.grid(row=1, column=1, padx=10, pady=10)

    def login():
        email = login_field.get().strip()
        password = password_field.get()
        if not email or not password:
            messagebox.showwarning('Ошибка', 'Поля не должны быть пустыми', parent=root)
            return
        try:
            user = get_user(email, password)
        except Exception as error:
            messagebox.showerror('Ошибка бд', f'Не удалось проверить пользователя:\n{error}', parent=root)
            return
        if user:
            open_main_window(root, user, open_root)
        else:
            messagebox.showerror('Авторизация', 'Неверный логин или пароль', parent=root)

    def enter_guest():
        open_main_window(root, None, open_root)

    Button(root, text='Вход', command=login, width=20).grid(row=2, column=1, pady=10)
    Button(root, text='Войти как гость', command=enter_guest, width=20).grid(row=3, column=1, pady=5)
