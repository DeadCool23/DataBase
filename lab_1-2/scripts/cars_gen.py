import csv
import random
import string

cars = {
    "Toyota": ["Camry", "Corolla", "Land Cruiser"],
    "BMW": ["X5", "X6", "3 Series", "5 Series", "7 Series"] + [f"M{i}" for i in range(2, 9)],
    "Mercedes-Benz": ["C-Class", "E-Class", "S-Class", "G-Class", "A-Class", "AMG GT", "GLA", "GLC", "GLE"],
    "Audi": [f"{l}{i}" for l in ("A", "RS", "Q") for i in range(1, 9)],
    "Lada": ["Vesta", "Granta", "Niva", "Priora"] + [f"2{i}" for i in range(101, 116)],
    "Ford": ["Focus", "Mondeo", "Explorer", "F-150", "Mustang"],
    "Volkswagen": ["Golf", "Passat", "Tiguan", "Polo"],
    "Hyundai": ["Solaris", "Tucson", "Santa Fe", "Elantra"],
    "Kia": ["Rio", "Sportage", "Sorento", "Ceed"],
    "Nissan": ["X-Trail", "Qashqai", "Teana", "Murano"],
    "Rolls-Royce": ["Phantom", "Ghost", "Wraith", "Cullinan"],
    "Cadillac": ["Escalade", "ATS", "CTS", "XT5", "XT6"],
    "Lincoln": ["Navigator", "Aviator", "MKZ", "Continental", "Corsair"],
    "Dodge": ["Charger", "Challenger", "Durango", "Ram", "Journey"],
    "Skoda": ["Octavia", "Superb", "Kodiaq", "Karoq", "Yetti"],
    "Porsche": ["Cayenne", "Macan", "911", "Panamera"]
}

def generate_vin():
    letters_and_digits = string.ascii_uppercase + string.digits
    vin = ''.join(random.choice(letters_and_digits) for _ in range(17))
    return vin

def generate_plate_number():
    letters = "АВЕКМНОРСТУХ"
    return f"{random.choice(letters)}{random.randint(100, 999)}{random.choice(letters)}{random.choice(letters)}{random.randint(1, 800):02d}"

def generate_car_data():
    brand = random.choice(list(cars.keys()))
    model = random.choice(cars[brand])
    year = random.randint(1980, 2024)
    vin = generate_vin()
    plate = generate_plate_number()
    return {
        "brand": brand,
        "model": model,
        "release_year": year,
        "vin": vin,
        "plate": plate
    }

def generate_and_save_cars_to_csv(filename, num_cars=1000, num_users=1000, num_requests=1000):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=["id", "user_id", "brand", "model", "release_year", "vin", "plate"])
        writer.writeheader()

        for car_id in range(1, num_cars + 1):
            car_data = generate_car_data()
            car_data["id"] = car_id
            car_data["user_id"] = random.randint(1, num_users)
            writer.writerow(car_data)