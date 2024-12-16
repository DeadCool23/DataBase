import csv
import random
from faker import Faker

fake = Faker("ru_RU")

TABLENAME = "users"

def generate_phone_number():
    area_code = '7'
    prefix = f'{random.randint(900, 999)}'
    line_number = f'{random.randint(1000000, 9999999)}'
    return f'+{area_code} ({prefix}) {line_number[:3]} {line_number[3:5]}-{line_number[5:]}'

def generate_user_data():
    last_name = fake.last_name_male()
    first_name = fake.first_name_male()

    email = fake.ascii_free_email()
    phone_number = generate_phone_number()

    return {
        "first_name": first_name,
        "last_name": last_name,
        "phone_number": phone_number,
        "email": email
    }

def generate_and_save_users_to_csv(filename, num_users=1000):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=["id", "first_name", "last_name", "phone_number", "email"])
        writer.writeheader()

        for user_id in range(1, num_users + 1):
            user_data = generate_user_data()
            user_data["id"] = user_id
            writer.writerow(user_data)