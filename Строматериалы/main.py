import tkinter as tk
from UI.login_window import open_login_window

root = tk.Tk()
root.title("СтройМатериалы - Авторизация")
root.geometry("420x320")
root.resizable(False, False)

open_login_window(root)

root.mainloop()