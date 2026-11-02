from tkinter import *
from tkinter import ttk, messagebox
from database import get_orders, delete_order
from UI.order_form import open_order_form


def open_orders_window(root, role_text):
    if role_text not in ('Менеджер', 'Администратор'):
        messagebox.showerror('Доступ', 'У вас нет прав на просмотр заказов', parent=root)
        return

    is_admin = role_text == 'Администратор'
    window = Toplevel(root)
    window.title('Заказы')
    window.geometry('1120x580')
    window.minsize(800, 450)

    top = Frame(window)
    top.pack(fill=X, padx=10, pady=10)
    Label(top, text='Список заказов', font=('Calibri', 16, 'bold')).pack(side=LEFT)
    Button(top, text='Назад', command=window.destroy).pack(side=RIGHT, padx=4)

    area = Frame(window)
    area.pack(fill=BOTH, expand=True, padx=10, pady=5)
    columns = ('composition', 'status', 'address', 'order_date', 'delivery_date', 'client', 'code')
    tree = ttk.Treeview(area, columns=columns, show='tree headings', height=16)
    tree.heading('#0', text='Заказ №')
    tree.column('#0', width=90, minwidth=70)
    labels = ['Состав / артикулы', 'Статус', 'Пункт выдачи', 'Дата заказа',
              'Дата выдачи', 'Клиент', 'Код получения']
    widths = [260, 120, 300, 105, 105, 190, 115]
    for col, label, width in zip(columns, labels, widths):
        tree.heading(col, text=label)
        tree.column(col, width=width, minwidth=65)

    yscroll = Scrollbar(area, orient=VERTICAL, command=tree.yview)
    xscroll = Scrollbar(area, orient=HORIZONTAL, command=tree.xview)
    tree.configure(yscrollcommand=yscroll.set, xscrollcommand=xscroll.set)
    yscroll.pack(side=RIGHT, fill=Y)
    xscroll.pack(side=BOTTOM, fill=X)
    tree.pack(side=LEFT, fill=BOTH, expand=True)

    def refresh_orders():
        try:
            orders = get_orders()
            for item in tree.get_children():
                tree.delete(item)
            for order in orders:
                tree.insert('', END, iid=str(order[0]), text=str(order[0]), values=(
                    order[1], order[2], order[3], str(order[4] or '—'),
                    str(order[5]), order[6], order[7]
                ))
        except Exception as error:
            messagebox.showerror('Ошибка БД', f'Не удалось загрузить заказы:\n{error}', parent=window)

    def selected_order():
        selection = tree.selection()
        if not selection:
            messagebox.showwarning('Заказы', 'Сначала выберите заказ', parent=window)
            return None
        return int(selection[0])

    opened_form = None

    def edit_order(order_id=None):
        nonlocal opened_form
        if not is_admin:
            return
        if opened_form is not None and opened_form.winfo_exists():
            opened_form.lift()
            return
        try:
            opened_form = open_order_form(window, order_id, refresh_orders, role_text)
        except Exception as error:
            messagebox.showerror('Ошибка формы', str(error), parent=window)

    def edit_selected(event=None):
        if is_admin:
            order_id = selected_order()
            if order_id is not None:
                edit_order(order_id)

    def remove_selected():
        if not is_admin:
            return
        order_id = selected_order()
        if order_id is None:
            return
        if not messagebox.askyesno('Удаление заказа', f'Удалить заказ №{order_id}?', parent=window):
            return
        try:
            delete_order(order_id)
            refresh_orders()
            messagebox.showinfo('Готово', 'Заказ удалён', parent=window)
        except Exception as error:
            messagebox.showerror('Удаление заказа', str(error), parent=window)

    if is_admin:
        Button(top, text='Удалить заказ', command=remove_selected).pack(side=RIGHT, padx=4)
        Button(top, text='Изменить заказ', command=edit_selected).pack(side=RIGHT, padx=4)
        Button(top, text='Добавить заказ', command=lambda: edit_order()).pack(side=RIGHT, padx=4)
        tree.bind('<Double-1>', edit_selected)

    refresh_orders()
    return window
