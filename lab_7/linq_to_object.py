from sqlalchemy import func
from sqlalchemy.orm import Session

from models import Users, Cars, Workers, Requests, Repairs

# 1. Вывести список всех пользователей - имя, фамилия и email
def get_users(session):
    data = session.query(Users.first_name, Users.last_name, Users.email).limit(5).all()
    for row in data:
        print((row.first_name, row.last_name, row.email))

# 2. Вывести все машины, у которых владелец с определённым ID
def get_cars_by_owner(session, owner_id):
    data = session.query(Cars).filter(Cars.user_id == owner_id).all()
    for row in data:
        print((row.id, row.brand, row.model, row.release_year))

# 3. Вывести среднюю стоимость ремонта
def get_avg_repair_costs(session):
    data = session.query(func.avg(Repairs.costs).label("avg_costs")).scalar()
    print(f"Средняя стоимость ремонта: {data}")

# 4. Вывести количество ремонтов для каждого статуса
def get_repairs_count_by_status(session):
    data = session.query(
        Repairs.repair_status,
        func.count(Repairs.id).label("count")
    ).group_by(Repairs.repair_status).all()
    for row in data:
        print((row.repair_status, row.count))

# 5. Вывести список автомобилей и их стоимость ремонта
def get_car_repair_costs(session):
    data = session.query(
        Cars.brand,
        Cars.model,
        func.sum(Repairs.costs).label("total_costs")
    ).join(Requests, Repairs.request_id == Requests.id) \
     .join(Cars, Requests.car_id == Cars.id) \
     .group_by(Cars.id) \
     .order_by(func.sum(Repairs.costs).desc()) \
     .limit(5) \
     .all()

    for row in data:
        print((row.brand, row.model, row.total_costs))




