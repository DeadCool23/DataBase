import os
from sqlalchemy.orm import class_mapper
from json import dumps, load

from models import Users

def serialize_all(model):
    columns = [c.key for c in class_mapper(model.__class__).columns]
    return dict((c, getattr(model, c)) for c in columns)

def users_to_json(session):
    serialized_users = [
        serialize_all(user)
        for user in session.query(Users).order_by(Users.id).all()
    ]

    with open('users.json', 'w', encoding='utf-8') as f:
        f.write(dumps(serialized_users, indent=4, ensure_ascii=False))
    print("Данные записаны в users.json")

def read_users_json(user_cnt=10):
    with open('users.json', 'r', encoding='utf-8') as f:
        users = load(f)

    for i in range(0, user_cnt):
        print(users[i])

