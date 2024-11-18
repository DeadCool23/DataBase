from sqlalchemy import select, insert, update, delete, text

from models import Users

# 1. Однотабличный запрос на выборку.
# Вывести имя, фамилию и email всех пользователей
def select_users(session):
    res = session.execute(
        select(Users.first_name, Users.last_name, Users.email).limit(5)
    )

    for user in res:
        print((user.first_name, user.last_name, user.email))

# 2. Многотабличный запрос на выборку.
# Вывести информацию о ремонтах, где стоимость ремонта превышает 500
def select_repairs_over_500(session):
    res = session.execute(text("""
        SELECT c.brand, c.model, r.costs, w.first_name || ' ' || w.last_name AS worker_name
        FROM repairs r
        JOIN requests req ON r.request_id = req.id
        JOIN cars c ON req.car_id = c.id
        JOIN workers w ON r.worker_id = w.id
        WHERE r.costs > 500;
    """))
    for repair in res:
        print(repair)

# 3. Добавление, изменение и удаление данных
# Добавление нового пользователя
def insert_user(session):
    try:
        id = int(input("ID: "))
        first_name = input("Имя: ")
        last_name = input("Фамилия: ")
        phone_number = input("Телефон: ")
        email = input("Email: ")

        session.execute(
            insert(Users).values(
                id=id,
                first_name=first_name,
                last_name=last_name,
                phone_number=phone_number,
                email=email
            )
        )
        session.commit()
        print("Пользователь успешно добавлен!")
    except Exception as e:
        print("Ошибка при добавлении пользователя:", e)

# Изменение номера телефона пользователя
def update_user_phone(session):
    user_id = int(input("ID пользователя: "))
    new_phone = input("Новый номер телефона: ")

    exists = session.query(
        session.query(Users).filter(Users.id == user_id).exists()
    ).scalar()

    if not exists:
        print("Такого пользователя нет!")
        return

    session.execute(
        update(Users).where(Users.id == user_id).values(phone_number=new_phone)
    )
    session.commit()
    print("Номер телефона успешно обновлён!")

# Удаление пользователя
def delete_user(session):
    user_id = int(input("ID пользователя для удаления: "))

    exists = session.query(
        session.query(Users).filter(Users.id == user_id).exists()
    ).scalar()

    if not exists:
        print("Такого пользователя нет!")
        return

    session.execute(
        delete(Users).where(Users.id == user_id)
    )
    session.commit()
    print("Пользователь успешно удалён!")

# 4. Вызов хранимой функции или процедуры.
# Вызов процедуры для подсчёта ремонтов по статусу
def call_repair_status_count(session):
    try:
        id = int(input("ID ремонта: "))
        status = input("Введите статус ремонта: ")
        session.execute(text(f"CALL update_repair_status({id}, '{status}');"))
        print(f"Статус ремонта с ID {id} изменен на '{status}'")
    except Exception as e:
        print("Ошибка при использовании процедуры update_repair_status: ", e)
