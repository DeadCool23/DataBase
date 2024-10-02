import csv
import random
from faker import Faker
from datetime import datetime

from .workers_gen import SPECIALIZATION
from .filenames import WORKERS_DATA_FILE, REQUESTS_DATA_FILE

fake = Faker("ru_RU")

workers = []

STATUS = [
    "В очереди",
    "Ремонтируется",
    "Ремонт окончен",
]

REPAIRS = [
    ("ТО", 5e+3),
    ("Поломка замков", 60e+3),
    ("Ошибки электроники", 40e+3),
    ("Полировка", 1e+3),
    ("Покраска", 1e+5),
    ("Замена шин", 15e+3),
    ("Ремонт вмятин", 20e+3)
]

def get_workers_by_specialization(specialization):
    return [worker for worker in workers if worker["specialization"] == specialization]

def generate_repair_data(request_date):
    status = random.choice(STATUS)
    repair_type, costs = random.choice(REPAIRS)

    _request_date = datetime.strptime(request_date, "%Y-%m-%d").date()
    date = fake.date_between(start_date=_request_date, end_date='today')
    spec_workers = get_workers_by_specialization(SPECIALIZATION[REPAIRS.index((repair_type, costs))])
    worker_id = random.choice(spec_workers)["id"]

    return {
        "worker_id": worker_id,
        "repair_status": status,
        "repair_type": repair_type,
        "costs": costs,
        "repair_date": date
    }

def read_data_from_file(file_path):
    with open(file_path, mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        return list(reader)

def generate_and_save_repairs_to_csv(filename, num_repairs=1000):
    global workers
    workers = read_data_from_file(WORKERS_DATA_FILE)
    requests = read_data_from_file(REQUESTS_DATA_FILE)

    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=["id", "worker_id", "request_id", "repair_status", "repair_type", "costs", "repair_date"])
        writer.writeheader()

        for repair_id in range(1, num_repairs + 1):
            request_id = int(random.choice(requests)["id"])
            repair_data = generate_repair_data(requests[request_id - 1]["request_date"])
            repair_data["id"] = repair_id
            repair_data["request_id"] = request_id

            writer.writerow(repair_data)