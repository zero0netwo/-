from tkinter import *
from tkinter import ttk, filedialog, messagebox
from pathlib import Path
from datetime import datetime
from PIL import Image
from database import get_product, get_reference, add_product, update_product, image_in_use


RESOURCES = Path(__file__).resolve().parent / 'resources'


def open_product_form(root, product_id, on_saved, role_text):
    if role_text != 'Администратор':
        raise ValueError('У вас нет прав для изменения товаров')

    product = get_product(product_id) if product_id is not None else None
    if product_id is not None and product is None:
        raise ValueError('Товар не найден')

    window = Toplevel(root)
    window.title('Редактирование товара' if product else 'Добавление товара')
    window.geometry('720x660')
    window.transient(root)
    window.grab_set()

    area = Frame(window)
    area.pack(fill=BOTH, expand=True, padx=18, pady=10)
    area.columnconfigure(1, weight=1)

    def label(row, title):
        Label(area, text=title).grid(row=row, column=0, sticky='w', pady=5)

    label(0, 'ID товара:')
    Label(area, text=str(product_id) if product else 'Назначается автоматически').grid(row=0, column=1, sticky='w')
    label(1, 'Артикул:')
    Label(area, text=product[1] if product else 'Будет создан автоматически').grid(row=1, column=1, sticky='w')

    label(2, 'Название:')
    name_entry = Entry(area, width=55)
    name_entry.grid(row=2, column=1, sticky='ew', pady=5)
    if product:
        name_entry.insert(0, product[2])

    boxes = {}
    references = [
        ('categories', 'Категория:', 7),
        ('manufacturers', 'Производитель:', 8),
        ('suppliers', 'Поставщик:', 9),
        ('units', 'Ед. измерения:', 10)
    ]
    for row, (table_name, title, product_index) in enumerate(references, start=3):
        label(row, title)
        options = get_reference(table_name)
        names = [name for id_value, name in options]
        box = ttk.Combobox(area, values=names, state='readonly', width=52)
        box.grid(row=row, column=1, sticky='ew', pady=5)
        if product:
            for id_value, text in options:
                if id_value == product[product_index]:
                    box.set(text)
                    break
        elif names:
            box.current(0)
        boxes[table_name] = (box, dict((text, id_value) for id_value, text in options))

    entries = {}
    for row, (name, title, index) in enumerate([
        ('price', 'Цена (руб.):', 3),
        ('discount', 'Скидка (%):', 4),
        ('stock', 'Остаток:', 5)
    ], start=7):
        label(row, title)
        entry = Entry(area, width=25)
        entry.grid(row=row, column=1, sticky='w', pady=5)
        entry.insert(0, str(product[index]) if product else ('0' if name != 'price' else ''))
        entries[name] = entry

    label(10, 'Описание:')
    description = Text(area, width=54, height=5, wrap=WORD)
    description.grid(row=10, column=1, sticky='ew', pady=5)
    if product and product[11]:
        description.insert('1.0', product[11])

    label(11, 'Фотография:')
    current_path = product[6] if product else None
    selected_photo = [None]
    photo_path = [current_path]
    photo_label = Label(area, text=current_path or 'Нет фотографии (будет заглушка)', wraplength=420, anchor='w')
    photo_label.grid(row=11, column=1, sticky='w', pady=4)

    def choose_photo():
        path = filedialog.askopenfilename(parent=window, title='Выбрать фото',
                                         filetypes=[('Изображения', '*.jpg *.jpeg *.png')])
        if not path:
            return
        try:
            with Image.open(path) as image:
                image.verify()
            selected_photo[0] = path
            photo_path[0] = current_path
            photo_label.config(text=Path(path).name)
        except (OSError, ValueError):
            messagebox.showerror('Фото', 'Не удалось прочитать изображение', parent=window)

    def clear_photo():
        selected_photo[0] = None
        photo_path[0] = None
        photo_label.config(text='Нет фотографии (будет заглушка)')

    photo_buttons = Frame(area)
    photo_buttons.grid(row=12, column=1, sticky='w', pady=5)
    Button(photo_buttons, text='Выбрать фото', command=choose_photo).pack(side=LEFT, padx=(0, 7))
    Button(photo_buttons, text='Убрать фото', command=clear_photo).pack(side=LEFT)

    def save():
        new_file = None
        try:
            name = name_entry.get().strip()
            if not name:
                raise ValueError('Введите название товара')
            if len(name) > 255:
                raise ValueError('Название слишком длинное')
            try:
                price = round(float(entries['price'].get().replace(',', '.')), 2)
                discount = float(entries['discount'].get().replace(',', '.'))
                stock = int(entries['stock'].get().strip())
            except ValueError:
                raise ValueError('Проверьте цену, скидку и остаток: нужны числа')
            if not (0 <= price <= 99999999.99):
                raise ValueError('Цена должна быть от 0 до 99999999.99')
            if price != price or discount != discount or abs(discount) == float('inf'):
                raise ValueError('Введите обычные конечные числа')
            if not (0 <= discount <= 100):
                raise ValueError('Скидка должна быть от 0 до 100%')
            if stock < 0:
                raise ValueError('Остаток не может быть отрицательным')
            ids = []
            for table_name in ('categories', 'manufacturers', 'suppliers', 'units'):
                box, lookup = boxes[table_name]
                if box.get() not in lookup:
                    raise ValueError('Выберите значение: ' + table_name)
                ids.append(lookup[box.get()])

            path_for_db = photo_path[0]
            if selected_photo[0]:
                photo_dir = RESOURCES / 'products'
                photo_dir.mkdir(parents=True, exist_ok=True)
                filename = 'photo_' + datetime.now().strftime('%Y%m%d_%H%M%S_%f') + '.jpg'
                new_file = photo_dir / filename
                with Image.open(selected_photo[0]) as source:
                    image = source.convert('RGB')
                    image.thumbnail((300, 200))
                    image.save(new_file, 'JPEG')
                path_for_db = 'resources/products/' + filename


            values = (name, ids[0], ids[1], ids[2], ids[3], price, discount,
                      stock, description.get('1.0', END).strip(), path_for_db)
            if product:
                update_product(product_id, values)
            else:
                add_product(values)

            # после успешного сохранения в бд удаляется старый файл
            if current_path and current_path != path_for_db:
                try:
                    if not image_in_use(current_path):
                        old_file = (Path(__file__).resolve().parent / current_path).resolve()
                        if old_file.parent == (RESOURCES / 'products').resolve() and old_file.is_file():
                            old_file.unlink()
                except OSError:
                    pass
            on_saved()
            messagebox.showinfo('Сохранено', 'Товар успешно сохранён', parent=window)
            window.destroy()
        except Exception as error:
            if new_file and new_file.is_file():
                try:
                    new_file.unlink()
                except OSError:
                    pass
            messagebox.showerror('Ошибка сохранения', str(error), parent=window)

    buttons = Frame(area)
    buttons.grid(row=13, column=1, sticky='w', pady=15)
    Button(buttons, text='Сохранить', bg='#B8860B', width=16, command=save).pack(side=LEFT, padx=4)
    Button(buttons, text='Отмена', width=12, command=window.destroy).pack(side=LEFT, padx=4)
    return window
