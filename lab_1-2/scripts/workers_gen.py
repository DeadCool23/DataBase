import csv
import random
from faker import Faker

from .gen_phone_number import generate_phone_number

fake = Faker("ru_RU")

SPECIALIZATION = [
    "Автомеханик",
    "Автослесарь",
    "Автоэлектрик",
    "Кузовщик",
    "Автомаляр",
    "Шиномонтажник",
    "Рихтовщик"
]

def generate_worker_data():
    last_name = fake.last_name_male()
    first_name = fake.first_name_male()

    specialization = random.choice(SPECIALIZATION)
    work_experience = random.randint(1, 31) + random.randint(0, 10) / 10

    phone_number = generate_phone_number()

    return {
        "first_name": first_name,
        "last_name": last_name,
        "specialization": specialization,
        "work_experience": work_experience,
        "phone_number": phone_number,
    }

def generate_and_save_workers_to_csv(filename, num_workers=1000):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=["id", "first_name", "last_name", "phone_number", "specialization", "work_experience"])
        writer.writeheader()

        for worker_id in range(1, num_workers + 1):
            worker_data = generate_worker_data()
            worker_data["id"] = worker_id
            writer.writerow(worker_data)