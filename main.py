from tkinter import *
from UI.auth_window import open_root

root = Tk()
root.option_add('*Font', 'Calibri 10')
root.title('Авторизация')
root.geometry('560x400')
open_root(root)
root.mainloop()
