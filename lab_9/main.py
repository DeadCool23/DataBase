import redis
import psycopg2
import json
from faker import Faker
from time import time, sleep
from random import randint

faker = Faker("ru_RU")

N_REPEATS = 5
USERS_COUNT = 0

def connection():
    try:
        con = psycopg2.connect(
            dbname="autoservice",
            user="nisu",
            password="1234",
            host="localhost",
            port="5432"
        )
    except Exception as e:
        print("Ошибка подключения к Базе Данных:", e)
        return None

    print("База данных успешно открыта")
    return con

def get_users_with_cache(cur):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)
    result = []

    for i in range(1, USERS_COUNT + 1):
        cache_value = redis_client.get(f"user_{i}")
        if cache_value:
            result.append(json.loads(cache_value))
        else:
            cur.execute("SELECT * FROM users_redis WHERE id = %s;", (i,))
            data = cur.fetchone()
            if data:
                result.append(data)
                redis_client.set(f"user_{i}", json.dumps(data, default=str))

    redis_client.close()
    return result


def get_users_db(cur):
    result = []

    for i in range(1, USERS_COUNT + 1):
        cur.execute("SELECT * FROM users_redis WHERE id = %s;", (i,))
        data = cur.fetchone()
        if data:
            result.append(data)

    return result


def select_user(cur):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    td1 = time()
    for i in range(1, USERS_COUNT + 1):
        cur.execute("SELECT * FROM users_redis WHERE id = %s;", (i,))
        cur.fetchone()
    td2 = time()

    for i in range(1, USERS_COUNT + 1):
        cur.execute("SELECT * FROM users_redis WHERE id = %s;", (i,))
        data = cur.fetchone()
        if data:
            redis_client.set(f"user_{i}", json.dumps(data, default=str))

    tr1 = time()
    for i in range(1, USERS_COUNT + 1):
        redis_client.get(f"user_{i}")
    tr2 = time()

    redis_client.close()
    return td2 - td1, tr2 - tr1

def insert_user(cur, con):
    global USERS_COUNT
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cur.execute("SELECT COUNT(*) FROM users_redis")
    count_users = cur.fetchone()[0]
    user_id = count_users + 1
    USERS_COUNT = user_id

    first_name = faker.first_name()
    last_name = faker.last_name()
    phone_number = f"+7 ({randint(900, 999)}) {randint(100, 999)} {randint(10, 99)}-{randint(10, 99)}"
    email = faker.email()

    td1 = time()
    cur.execute(
        f"""
        INSERT INTO users_redis (id, first_name, last_name, phone_number, email)
        VALUES ({user_id}, '{first_name}', '{last_name}', '{phone_number}', '{email}');
        """
    )
    td2 = time()
    con.commit()

    cur.execute("SELECT * FROM users_redis where id = %s;", (user_id,))
    new_user = cur.fetchone()

    data = json.dumps(new_user, default=str)
    tr1 = time()
    redis_client.set(f"user_{user_id}", data)
    tr2 = time()

    redis_client.close()

    print("Добавлен пользователь:", new_user)
    return td2 - td1, tr2 - tr1

def delete_user(cur, con):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cur.execute("SELECT MAX(id) FROM users_redis")
    max_id = cur.fetchone()[0]

    if max_id is None:
        print("Нет пользователей для удаления.")
        return 0, 0

    cur.execute(f"SELECT * FROM users_redis WHERE id = {max_id};")
    user_to_delete = cur.fetchone()
    print("Удаляем пользователь:", user_to_delete)

    td1 = time()
    cur.execute(f"DELETE FROM users_redis WHERE id = {max_id};")
    td2 = time()
    con.commit()

    tr1 = time()
    redis_client.delete(f"user_{max_id}")
    tr2 = time()

    redis_client.close()

    return td2 - td1, tr2 - tr1

def update_user(cur, con):
    redis_client = redis.Redis(host="localhost", port=6379, db=0)

    cur.execute("SELECT MAX(id) FROM users_redis")
    max_id = cur.fetchone()[0]

    if max_id is None:
        print("Нет пользователей для обновления.")
        return 0, 0

    new_email = faker.email()
    print(f"Обновляем email для пользователя с ID {max_id} на {new_email}")

    td1 = time()
    cur.execute(f"UPDATE users_redis SET email = '{new_email}' WHERE id = {max_id};")
    td2 = time()
    con.commit()

    cur.execute(f"SELECT * FROM users_redis WHERE id = {max_id};")
    updated_user = cur.fetchone()

    data = json.dumps(updated_user, default=str)
    tr1 = time()
    redis_client.set(f"user_{max_id}", data)
    tr2 = time()

    redis_client.close()

    return td2 - td1, tr2 - tr1

def compare_times(cur, con):
    print("Сравнение: Чтение данных")
    t1, t2 = 0, 0
    for _ in range(N_REPEATS):
        td, tr = select_user(cur)
        t1 += td
        t2 += tr
    print(f"Среднее время чтения:\n\tБД: {t1 / N_REPEATS}\n\tRedis: {t2 / N_REPEATS}")

    print("Сравнение: Вставка данных")
    t1, t2 = 0, 0
    for _ in range(N_REPEATS):
        td, tr = insert_user(cur, con)
        t1 += td
        t2 += tr
        sleep(1)
    print(f"Среднее время вставки:\n\tБД: {t1 / N_REPEATS}\n\tRedis: {t2 / N_REPEATS}")

    print("Сравнение: Удаление данных")
    t1, t2 = 0, 0
    for _ in range(N_REPEATS):
        td, tr = delete_user(cur, con)
        t1 += td
        t2 += tr
        sleep(1)
    print(f"Среднее время удаления:\n\tБД: {t1 / N_REPEATS}\n\tRedis: {t2 / N_REPEATS}")

    print("Сравнение: Обновление данных")
    t1, t2 = 0, 0
    for _ in range(N_REPEATS):
        td, tr = update_user(cur, con)
        t1 += td
        t2 += tr
        sleep(1)
    print(f"Среднее время обновления:\n\tБД: {t1 / N_REPEATS}\n\tRedis: {t2 / N_REPEATS}")

def main():
    global USERS_COUNT
    con = connection()
    if not con:
        return
    cur = con.cursor()
    cur.execute("SELECT COUNT(*) FROM users_redis")
    USERS_COUNT = cur.fetchone()[0]

    while True:
        print("\nМеню:")
        print("1. Получить пользователей с Redis")
        print("2. Получить пользователей из БД")
        print("3. Вставить нового пользователя")
        print("4. Удалить пользователя")
        print("5. Обновить пользователя")
        print("6. Сравнение времени выполнения")
        print("0. Выход")

        try:
            choice = int(input("Выберите действие: "))
        except:
            choice = -1
        
        if choice == 0:
            break
        elif choice == 1:
            users = get_users_with_cache(cur)
            for user in users:
                print(user)
        elif choice == 2:
            users = get_users_db(cur)
            for user in users:
                print(user)
        elif choice == 3:
            insert_user(cur, con)
        elif choice == 4:
            delete_user(cur, con)
        elif choice == 5:
            update_user(cur, con)
        elif choice == 6:
            compare_times(cur, con)
        else:
            print("Неверная команда!")

if __name__ == "__main__":
    main()
