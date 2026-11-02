from tkinter import *
from tkinter import ttk, messagebox
from pathlib import Path
from PIL import Image, ImageTk
from database import get_products, get_reference, delete_product, image_in_use
from UI.product_form import open_product_form
from UI.orders_window import open_orders_window


RESOURCES = Path(__file__).resolve().parent / 'resources'


def open_main_window(root, user, open_root):
    for widget in root.winfo_children():
        widget.destroy()

    root.title('Каталог товаров')
    root.geometry('1120x720')
    root.minsize(800, 550)

    if user is None:
        full_name_text = 'Гость'
        role_text = 'Гость'
    else:
        full_name_text = user[1]
        role_text = user[3]

    is_manager = role_text in ('Менеджер', 'Администратор')
    is_admin = role_text == 'Администратор'
    products = []

    frame = Frame(root, borderwidth=1, relief=SOLID, bg='#DAA520')
    frame.pack(fill=X, padx=5, pady=5)
    # Логотип
    try:
        with Image.open(RESOURCES / 'icon.png') as source:
            logo_image = source.copy()
        logo_image.thumbnail((40, 40))
        logo = ImageTk.PhotoImage(logo_image)
        logo_label = Label(frame, image=logo, bg='#DAA520')
        logo_label.pack(side=LEFT, padx=(10, 0), pady=4)
        logo_label.image = logo
        root.iconphoto(True, logo)
    except (OSError, ValueError, TclError):
        pass
    company_name = Label(frame, text='СтройМатериалы', font=('Calibri', 18, 'bold'), bg='#DAA520')
    company_name.pack(side=LEFT, padx=12, pady=8)

    def logout():
        for widget in root.winfo_children():
            widget.destroy()
        root.title('Авторизация')
        root.geometry('560x400')
        open_root(root)

    exit_button = Button(frame, text='Выход', command=logout)
    exit_button.pack(side=RIGHT, padx=10)
    role_label = Label(frame, text=role_text, bg='#DAA520')
    role_label.pack(side=RIGHT, padx=8)
    full_name = Label(frame, text=full_name_text, bg='#DAA520')
    full_name.pack(side=RIGHT, padx=8)

    if is_manager:
        search_frame = Frame(root)
        search_frame.pack(fill=X, padx=10, pady=5)
        search_var = StringVar()
        Label(search_frame, text='Поиск:').pack(side=LEFT, padx=4)
        search_entry = Entry(search_frame, width=25, textvariable=search_var)
        search_entry.pack(side=LEFT, padx=4)

        Label(search_frame, text='Производитель:').pack(side=LEFT, padx=4)
        manufacturer_box = ttk.Combobox(search_frame, state='readonly', width=21)
        manufacturer_box.pack(side=LEFT, padx=4)

        Label(search_frame, text='Сортировка:').pack(side=LEFT, padx=4)
        sort_box = ttk.Combobox(search_frame, state='readonly', width=15, values=[
            'Цена ↑', 'Цена ↓', 'Скидка ↑', 'Скидка ↓', 'Остаток ↑', 'Остаток ↓'
        ])
        sort_box.pack(side=LEFT, padx=4)
        sort_box.current(0)

    actions = Frame(root)
    actions.pack(fill=X, padx=10, pady=4)
    Label(actions, text='Каталог товаров', font=('Calibri', 15, 'bold')).pack(side=LEFT)
    count_label = Label(actions, text='')
    count_label.pack(side=LEFT, padx=18)

    def open_orders():
        if is_manager:
            open_orders_window(root, role_text)

    if is_manager:
        Button(actions, text='Заказы', command=open_orders).pack(side=RIGHT, padx=4)

    # каталог
    catalog_area = Frame(root)
    catalog_area.pack(fill=BOTH, expand=True)
    canvas = Canvas(catalog_area, highlightthickness=0)
    frame_products = Frame(canvas)
    canvas.pack(side=LEFT, fill=BOTH, expand=True)
    canvas_window = canvas.create_window((0, 0), window=frame_products, anchor='nw')

    def update_canvas_width(event):
        canvas.itemconfigure(canvas_window, width=event.width)

    canvas.bind('<Configure>', update_canvas_width)
    scroll = Scrollbar(catalog_area, orient=VERTICAL, command=canvas.yview)
    scroll.pack(side=RIGHT, fill=Y)
    canvas.config(yscrollcommand=scroll.set)

    def update_scroll(event):
        canvas.config(scrollregion=canvas.bbox('all'))

    frame_products.bind('<Configure>', update_scroll)


    def load_photo(image_path):
        if image_path:
            path = Path(image_path)
            if not path.is_absolute():
                path = Path(__file__).resolve().parent / path
        else:
            path = RESOURCES / 'picture.png'
        if not path.is_file():
            path = RESOURCES / 'picture.png'
        try:
            with Image.open(path) as source:
                image = source.copy()
            image.thumbnail((100, 100))
            return ImageTk.PhotoImage(image)
        except (OSError, ValueError):
            return None

    def remove_product(product_id, image_path):
        if not is_admin:
            return
        if not messagebox.askyesno('Удаление товара', 'Удалить выбранный товар без возможности отмены?', parent=root):
            return
        try:
            delete_product(product_id)
            # удаление уникальной фотки
            if image_path and not image_in_use(image_path):
                old_file = (Path(__file__).resolve().parent / image_path).resolve()
                photo_dir = (RESOURCES / 'products').resolve()
                if old_file.parent == photo_dir and old_file.is_file():
                    old_file.unlink()
            refresh_products()
            messagebox.showinfo('Готово', 'Товар удалён', parent=root)
        except Exception as error:
            messagebox.showerror('Не удалось удалить', str(error), parent=root)

    opened_product_form = None

    def edit_product(product_id=None):
        nonlocal opened_product_form
        if not is_admin:
            return
        if opened_product_form is not None and opened_product_form.winfo_exists():
            opened_product_form.lift()
            return
        try:
            opened_product_form = open_product_form(root, product_id, refresh_products, role_text)
        except Exception as error:
            messagebox.showerror('Ошибка формы', str(error), parent=root)

    if is_admin:
        Button(actions, text='Добавить товар', command=lambda: edit_product()).pack(side=RIGHT, padx=4)

    def render_product(filtered_products):
        for widget in frame_products.winfo_children():
            widget.destroy()
        count_label.config(text=f'Найдено: {len(filtered_products)}')
        if not filtered_products:
            Label(frame_products, text='Товары не найдены', font=('Calibri', 13)).pack(pady=25)
            return

        for view_products in filtered_products:
            product_id = view_products[0]
            original_price = view_products[3]
            discount = view_products[4]
            final_price = original_price - original_price * discount / 100
            quantity = view_products[5]
            if quantity == 0:
                card_color = '#ADD8E6'
            elif discount > 12:
                card_color = '#F4A460'
            else:
                card_color = '#F0F0F0'

            product_frame = Frame(frame_products, borderwidth=1, relief=SOLID, bg=card_color)
            product_frame.pack(fill=X, pady=7, padx=10)
            photo = load_photo(view_products[6])
            image_label = Label(product_frame, image=photo, bg=card_color, width=112)
            image_label.pack(side=LEFT, padx=8, pady=10)
            image_label.image = photo


            right_frame = Frame(product_frame, bg=card_color)
            right_frame.pack(side=RIGHT, padx=10, pady=8)
            if discount > 0:
                Label(right_frame, text=f'{original_price:.2f} ₽', fg='red', bg=card_color,
                      font=('Calibri', 11, 'overstrike')).pack(anchor='e')
            Label(right_frame, text=f'{final_price:.2f} ₽', bg=card_color,
                  font=('Calibri', 13, 'bold')).pack(anchor='e', pady=3)
            Label(right_frame, text=f'Скидка: {discount:g}%', bg=card_color).pack(anchor='e')
            if is_admin:
                Button(right_frame, text='Изменить', command=lambda pid=product_id: edit_product(pid)).pack(fill=X, pady=(8, 2))
                Button(right_frame, text='Удалить', command=lambda pid=product_id, p=view_products[6]: remove_product(pid, p)).pack(fill=X)

            info_frame = Frame(product_frame, bg=card_color)
            info_frame.pack(side=LEFT, fill=BOTH, expand=True, pady=7)
            product_info = [
                f'Артикул: {view_products[1]}',
                f'Название товара: {view_products[2]}',
                f'Категория: {view_products[12]}',
                f'Производитель: {view_products[13]}',
                f'Поставщик: {view_products[14]}',
                f'Ед. изм.: {view_products[15]}  |  Осталось: {quantity}',
                f'Описание: {view_products[11] or "—"}'
            ]
            for line in product_info:
                Label(info_frame, text=line, bg=card_color, anchor='w', justify=LEFT,
                      wraplength=510).pack(anchor='w', padx=5, pady=2)

        canvas.yview_moveto(0)

    def update_catalog(*args):
        filtered_products = []
        if is_manager:

            words = search_var.get().lower().split()
            selected_manufacturer = manufacturer_box.get()
        else:
            words = []
            selected_manufacturer = 'Все производители'

        for product in products:
            if selected_manufacturer not in ('', 'Все производители'):
                if product[13] != selected_manufacturer:
                    continue
            search_text = ' '.join(str(value or '') for value in (
                product[1], product[2], product[11], product[12],
                product[13], product[14], product[15]
            )).lower()
            if all(word in search_text for word in words):
                filtered_products.append(product)

        if is_manager:
            selected_sort = sort_box.current()
            if selected_sort < 0:
                selected_sort = 0
            # цена=3, скидка=4, остаток=5
            sort_indexes = [3, 3, 4, 4, 5, 5]
            filtered_products.sort(key=lambda p: p[sort_indexes[selected_sort]],
                                   reverse=(selected_sort % 2 == 1))
        render_product(filtered_products)

    def refresh_products():
        nonlocal products
        try:
            products = get_products()
            if is_manager:
                manufacturers = [row[1] for row in get_reference('manufacturers')]
                previous = manufacturer_box.get()
                manufacturer_box['values'] = ['Все производители'] + manufacturers
                if previous in manufacturer_box['values']:
                    manufacturer_box.set(previous)
                else:
                    manufacturer_box.current(0)
            update_catalog()
        except Exception as error:
            messagebox.showerror('Ошибка базы данных', f'Не удалось загрузить каталог:\n{error}', parent=root)

    if is_manager:
        search_var.trace_add('write', update_catalog)
        manufacturer_box.bind('<<ComboboxSelected>>', update_catalog)
        sort_box.bind('<<ComboboxSelected>>', update_catalog)

    refresh_products()
