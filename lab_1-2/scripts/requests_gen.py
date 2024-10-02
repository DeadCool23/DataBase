import csv
import random
from faker import Faker

fake = Faker("ru_RU")

STATUS = [
    "В очереди",
    "Ремонтируется",
    "Готов к выдаче",
    "Получен клиентом"
]

def generate_request_data():
    status = random.choice(STATUS)
    date = fake.date_between(start_date='-5M', end_date='today')

    return {
        "request_status": status,
        "request_date": date
    }

def generate_and_save_requests_to_csv(filename, num_requests=1000, num_cars=1000):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=["id", "car_id", "request_status", "request_date"])
        writer.writeheader()

        for request_id in range(1, num_requests + 1):
            request_data = generate_request_data()
            request_data["id"] = request_id
            request_data["car_id"] = (request_id - 1) % num_cars + 1
            writer.writerow(request_data)