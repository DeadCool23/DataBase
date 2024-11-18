import psycopg2

def connect_to_db():
    conn = psycopg2.connect(
        dbname="autoservice",
        user="nisu",
        password="1234",
        host="localhost",
        port="5432"
    )
    return conn

def scalar_query(conn):
    with conn.cursor() as cursor:
        cursor.execute("SELECT COUNT(*) FROM workers;")
        result = cursor.fetchone()
        print("Количество работников:", result[0])

def join_query(conn, user_id):
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT u.first_name, u.last_name, c.brand, c.model, c.plate
            FROM users u
            JOIN cars c ON u.id = c.user_id
            WHERE u.id = %s;
        """, (user_id, ))
        i = 0
        for row in cursor.fetchall():
            if i == 0:
                print(f"\nПользователь с ID={user_id}: {row[0]}  {row[1]}")
            print(f"Машина {i+1}: {row[2]} {row[3]} {row[4]}")
            i += 1

def cte_window_query(conn, cars_cnt):
    with conn.cursor() as cursor:
        cursor.execute("""
            WITH CarAges AS (
                SELECT id, brand, model, release_year,
                       EXTRACT(YEAR FROM CURRENT_DATE) - release_year AS age
                FROM cars
            )
            SELECT brand, model, release_year, age,
                   ROW_NUMBER() OVER (ORDER BY age) as rank
            FROM CarAges
            LIMIT(%s);
        """, (cars_cnt, ))
        print(f"{'Rank':5}|{'Brand':20}|{'Model':20}|{'Realise':10}|{'Age':5}")
        for row in cursor.fetchall():
            print(f"{row[4]:5}|{row[0]:20}|{row[1]:20}|{row[2]:10}|{row[3]:5}")

def metadata_query(conn):
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_name = 'users';
        """)
        for row in cursor.fetchall():
            print(f"Имя столбца: {row[0]}, Тип данных: {row[1]}")

def call_scalar_function(conn, user_id):
    with conn.cursor() as cursor:
        cursor.execute("SELECT get_user_full_name(%s);", (user_id,))
        print("Полное имя пользователя:", cursor.fetchone()[0])

def call_table_function(conn, request_id):
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM get_repair_details(%s);", (request_id,))
        print(f"{'Repair_id':10}|{'Worker Full name':30}|{'Status':20}|{'Repair type':20}|{'Cost':20}|{'Date':}")
        for row in cursor.fetchall():
            print(f"{row[0]:10}|{row[1]:30}|{row[2]:20}|{row[3]:20}|{row[4]:20}|{row[5]:}")

def call_stored_procedure(conn, repair_id, new_status):
    with conn.cursor() as cursor:
        cursor.execute("CALL update_repair_status(%s, %s);", (repair_id, new_status))
        conn.commit()
        print("Статус ремонта обновлен")

def call_system_function(conn):
    with conn.cursor() as cursor:
        cursor.execute("SELECT CURRENT_DATE;")
        print("Текущая дата:", cursor.fetchone()[0])

def create_table(conn):
    with conn.cursor() as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS service_logs (
                log_id SERIAL PRIMARY KEY,
                log_message VARCHAR(255),
                log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        conn.commit()
        print("Таблица service_logs создана")

def is_table_exists(conn):
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_name = 'service_logs'
            );
        """)
        exists = cursor.fetchone()[0]

def insert_data(conn, log_message):
    if not is_table_exists(conn):
        print("Таблицы service_logs не существует")
        return
    with conn.cursor() as cursor:
        cursor.execute("INSERT INTO service_logs (log_message) VALUES (%s);", (log_message,))
        conn.commit()
        print("Запись добавлена")
