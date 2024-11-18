from sqlalchemy.orm import Session, sessionmaker, class_mapper

import eng
from linq_to_sql import *
from linq_to_object import *
from linq_to_json import read_users_json, users_to_json

# Пример вызова функций
if __name__ == "__main__":
    engine = eng.get_db_engine()
    engine.connect()

    session = Session(engine)

    print("=======LINQ to Object=======")

    print("Список пользователей:")
    get_users(session)

    print("\nМашины пользователя с ID 1:")
    get_cars_by_owner(session, owner_id=1)

    print("\nСредняя стоимость ремонта:")
    get_avg_repair_costs(session)

    print("\nКоличество ремонтов по статусам:")
    get_repairs_count_by_status(session)

    print("\nАвтомобили и их общая стоимость ремонта:")
    get_car_repair_costs(session)

    print("=======LINQ to JSON=======")

    users_to_json(session)

    read_users_json()

    print("=======LINQ to SQL=======")

    print("Список пользователей:")
    select_users(session)

    print("\nРемонты с ценой выше 500:")
    select_repairs_over_500(session)

    print("\nДобавление пользователя:")
    insert_user(session)

    print("\nОбновление телефона пользователя:")
    update_user_phone(session)

    print("\nУдаление пользователя:")
    delete_user(session)

    print("\nКоличество ремонтов по статусу:")
    call_repair_status_count(session)