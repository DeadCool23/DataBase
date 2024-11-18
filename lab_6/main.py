import database as db
from menu import main_menu
import input_output as io

def main():
    conn = db.connect_to_db()
    while True:
        choice = main_menu()
        if choice == "1":
            db.scalar_query(conn)
        elif choice == "2":
            user_id = io.id_input("Введите ID пользователя: ")
            
            if user_id < 0:
                print("Неверный ID пользователя")
                continue
            db.join_query(conn, user_id)
        elif choice == "3":
            cars_cnt = io.int_input("Введите кол-во машин которое хотите увидеть: ")

            if cars_cnt < 0:
                print("Неверное кол-во машин")
                continue
            db.cte_window_query(conn, cars_cnt)
        elif choice == "4":
            db.metadata_query(conn)
        elif choice == "5":
            user_id = io.id_input("Введите ID пользователя: ")
            
            if user_id < 0:
                print("Неверный ID пользователя")
                continue
            db.call_scalar_function(conn, user_id)
        elif choice == "6":
            request_id = io.id_input("Введите ID заявки: ")
            
            if request_id < 0:
                print("Неверный ID заявки")
                continue
            db.call_table_function(conn, request_id)
        elif choice == "7":
            repair_id = io.id_input("Введите ID ремонта: ")

            if repair_id < 0:
                print("Неверный ID ремонта")
                continue
            new_status = input("Введите новый статус: ")
            db.call_stored_procedure(conn, repair_id, new_status)
        elif choice == "8":
            db.call_system_function(conn)
        elif choice == "9":
            db.create_table(conn)
        elif choice == "10":
            log_message = input("Введите сообщение для лога: ")
            db.insert_data(conn, log_message)
        elif choice == "0":
            conn.close()
            break
        else:
            print("Неверный выбор.")

if __name__ == "__main__":
    main()
