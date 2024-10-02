from scripts.filenames import *

from scripts.cars_gen import generate_and_save_cars_to_csv
from scripts.users_gen import generate_and_save_users_to_csv
from scripts.workers_gen import generate_and_save_workers_to_csv
from scripts.requests_gen import generate_and_save_requests_to_csv
from scripts.repairs_gen import generate_and_save_repairs_to_csv

if "__main__" == __name__:
    generate_and_save_users_to_csv(USERS_DATA_FILE)
    generate_and_save_cars_to_csv(CARS_DATA_FILE)
    
    generate_and_save_requests_to_csv(REQUESTS_DATA_FILE)

    generate_and_save_workers_to_csv(WORKERS_DATA_FILE)
    generate_and_save_repairs_to_csv(REPAIRS_DATA_FILE)

    print("Данные успешно сгенерированы")
