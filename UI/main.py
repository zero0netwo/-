from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from UI.auth_window import open_root
from tkinter import *

root = Tk()
root.option_add('*Font', 'Calibri 10')
root.title('Авторизация')
root.geometry('560x400')
open_root(root)
root.mainloop()
