from tkinter import *
from tkinter import ttk, messagebox
from datetime import date
from database import (get_order, get_order_items, get_reference,
                      get_product_choices, save_order)


def open_order_form(parent, order_id, on_saved, role_text):
    if role_text != 'Администратор':
        raise ValueError('У вас нет прав на изменение заказов')
    order = get_order(order_id) if order_id is not None else None
    if order_id is not None and order is None:
        raise ValueError('Заказ не найден')

    window = Toplevel(parent)
    window.title(f'Изменение заказа №{order_id}' if order else 'Добавление заказа')
    window.geometry('760x660')
    window.transient(parent)
    window.grab_set()
    area = Frame(window)
    area.pack(fill=BOTH, expand=True, padx=16, pady=12)
    area.columnconfigure(1, weight=1)

    Label(area, text=f'Заказ №{order_id}' if order else 'Новый заказ',
          font=('Calibri', 16, 'bold')).grid(row=0, column=0, columnspan=2, sticky='w', pady=8)

    def make_combo(row, title, table, saved_id=None):
        Label(area, text=title).grid(row=row, column=0, sticky='w', pady=5)
        options = get_reference(table)
        captions = [f'{key}: {text}' for key, text in options]
        values = dict(zip(captions, (key for key, text in options)))
        box = ttk.Combobox(area, values=captions, state='readonly', width=57)
        box.grid(row=row, column=1, sticky='ew', pady=5)
        if saved_id is not None:
            for caption, key in values.items():
                if key == saved_id:
                    box.set(caption)
                    break
        elif captions:
            box.current(0)
        return box, values

    client_box, client_values = make_combo(1, 'Клиент:', 'users', order[1] if order else None)
    point_box, point_values = make_combo(2, 'Пункт выдачи:', 'pickup_points', order[2] if order else None)
    status_box, status_values = make_combo(3, 'Статус:', 'order_statuses', order[3] if order else None)

    def make_entry(row, title, value):
        Label(area, text=title).grid(row=row, column=0, sticky='w', pady=5)
        entry = Entry(area, width=30)
        entry.grid(row=row, column=1, sticky='w', pady=5)
        if value is not None:
            entry.insert(0, str(value))
        return entry

    order_date = make_entry(4, 'Дата заказа (ГГГГ-ММ-ДД):', order[4] if order else date.today())
    delivery_date = make_entry(5, 'Дата выдачи (ГГГГ-ММ-ДД):', order[5] if order else date.today())
    code_entry = make_entry(6, 'Код получения:', order[6] if order else '')

    Label(area, text='Состав заказа', font=('Calibri', 12, 'bold')).grid(row=7, column=0, columnspan=2, sticky='w', pady=(12, 5))
    choices = get_product_choices()
    names = [f'{p[1]} — {p[2]}' for p in choices]
    names_to_ids = dict((f'{p[1]} — {p[2]}', p[0]) for p in choices)
    ids_to_names = dict((p[0], f'{p[1]} — {p[2]}') for p in choices)
    Label(area, text='Товар:').grid(row=8, column=0, sticky='w', pady=5)
    product_box = ttk.Combobox(area, values=names, state='readonly', width=57)
    product_box.grid(row=8, column=1, sticky='ew')
    if names:
        product_box.current(0)
    Label(area, text='Количество:').grid(row=9, column=0, sticky='w')
    qty_entry = Entry(area, width=12)
    qty_entry.grid(row=9, column=1, sticky='w')
    qty_entry.insert(0, '1')

    items = dict(get_order_items(order_id)) if order else {}
    items_tree = ttk.Treeview(area, columns=('count',), show='tree headings', height=6)
    items_tree.heading('#0', text='Артикул и название')
    items_tree.heading('count', text='Количество')
    items_tree.column('#0', width=455)
    items_tree.column('count', width=105, anchor='center')
    items_tree.grid(row=11, column=0, columnspan=2, sticky='nsew', pady=8)
    area.rowconfigure(11, weight=1)

    def render_items():
        for row in items_tree.get_children():
            items_tree.delete(row)
        for product_id, quantity in items.items():
            items_tree.insert('', END, iid=str(product_id),
                              text=ids_to_names.get(product_id, f'Товар №{product_id}'),
                              values=(quantity,))

    def add_item():
        if product_box.get() not in names_to_ids:
            messagebox.showwarning('Товары', 'Выберите товар', parent=window)
            return
        try:
            qty = int(qty_entry.get())
            if qty <= 0:
                raise ValueError()
        except ValueError:
            messagebox.showwarning('Количество', 'Количество должно быть целым положительным числом', parent=window)
            return
        product_id = names_to_ids[product_box.get()]
        items[product_id] = qty
        render_items()

    def remove_item():
        selected = items_tree.selection()
        if selected:
            items.pop(int(selected[0]), None)
            render_items()

    buttons = Frame(area)
    buttons.grid(row=10, column=1, sticky='w', pady=8)
    Button(buttons, text='Добавить / изменить', command=add_item).pack(side=LEFT, padx=4)
    Button(buttons, text='Убрать выбранный', command=remove_item).pack(side=LEFT, padx=4)

    def save():
        try:
            if client_box.get() not in client_values:
                raise ValueError('Выберите клиента')
            if point_box.get() not in point_values:
                raise ValueError('Выберите пункт выдачи')
            if status_box.get() not in status_values:
                raise ValueError('Выберите статус')
            if not items:
                raise ValueError('Добавьте хотя бы один товар')
            order_text = order_date.get().strip()

            if not order_text and order and order[4] is None:
                first_date = None
            else:
                first_date = date.fromisoformat(order_text)
            last_date = date.fromisoformat(delivery_date.get().strip())
            if first_date and last_date < first_date:
                raise ValueError('Дата выдачи не может быть раньше даты заказа')
            code = code_entry.get().strip()
            if not code or len(code) > 20:
                raise ValueError('Укажите код получения (до 20 символов)')
            values = (client_values[client_box.get()], point_values[point_box.get()],
                      status_values[status_box.get()], first_date, last_date, code)
            save_order(order_id, values, list(items.items()))
            on_saved()
            messagebox.showinfo('Сохранено', 'Заказ сохранён', parent=window)
            window.destroy()
        except ValueError as error:
            messagebox.showerror('Ошибка данных', f'Проверьте поля формы:\n{error}', parent=window)
        except Exception as error:
            messagebox.showerror('Ошибка сохранения', str(error), parent=window)

    render_items()
    row_buttons = Frame(area)
    row_buttons.grid(row=12, column=1, sticky='w', pady=8)
    Button(row_buttons, text='Сохранить заказ', bg='#B8860B', command=save).pack(side=LEFT, padx=4)
    Button(row_buttons, text='Отмена', command=window.destroy).pack(side=LEFT, padx=4)
    return window
