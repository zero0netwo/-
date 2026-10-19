
import tkinter as tk


def open_main_window(root, user, on_logout):
    for widget in root.winfo_children():
        widget.destroy()

    root.title("СтройМатериалы - Главное окно")
    root.geometry("800x500")
    root.resizable(True, True)

    if user is None:
        full_name = "Гость"
        role = "Гость"
    else:
        full_name = user[1]
        role = user[2]

    def logout():
        on_logout(root)

    header = tk.Frame(root, bg="#DAA520")
    header.pack(fill="x")

    title_label = tk.Label(
        header,
        text="СтройМатериалы",
        font=("Calibri", 16, "bold"),
        bg="#DAA520"
    )
    title_label.pack(side="left", padx=20, pady=15)

    user_label = tk.Label(
        header,
        text=full_name,
        font=("Calibri", 12),
        bg="#DAA520"
    )
    user_label.pack(side="right", padx=20)

    logout_button = tk.Button(
        header,
        text="Выйти",
        command=logout
    )
    logout_button.pack(side="right", padx=10)

    welcome_label = tk.Label(
        root,
        text="Добро пожаловать!",
        font=("Calibri", 20, "bold")
    )
    welcome_label.pack(pady=30)

    role_label = tk.Label(
        root,
        text=f"Ваша роль: {role}",
        font=("Calibri", 14)
    )
    role_label.pack(pady=10)

    info_label = tk.Label(
        root,
        text="Здесь будет отображаться каталог товаров",
        font=("Calibri", 12)
    )
    info_label.pack(pady=20)
