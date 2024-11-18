from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, ForeignKey, Float, Date

Base = declarative_base()

class Users(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    phone_number = Column(String(18), unique=True, nullable=False)
    email = Column(String(50), unique=True, nullable=False)

    cars = relationship("Cars", back_populates="owner")


class Cars(Base):
    __tablename__ = "cars"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    brand = Column(String(50), nullable=False)
    model = Column(String(50), nullable=False)
    release_year = Column(Integer, nullable=False)
    vin = Column(String(17), nullable=False, unique=True)
    plate = Column(String(10), nullable=False)

    owner = relationship("Users", back_populates="cars")
    requests = relationship("Requests", back_populates="car")


class Workers(Base):
    __tablename__ = "workers"

    id = Column(Integer, primary_key=True)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    phone_number = Column(String(18), nullable=False)
    specialization = Column(String(50), nullable=False)
    work_experience = Column(Float, nullable=False)

    repairs = relationship("Repairs", back_populates="worker")


class Requests(Base):
    __tablename__ = "requests"

    id = Column(Integer, primary_key=True)
    car_id = Column(Integer, ForeignKey("cars.id"), nullable=False)
    request_status = Column(String(50), nullable=False)
    request_date = Column(Date, nullable=False)

    car = relationship("Cars", back_populates="requests")
    repairs = relationship("Repairs", back_populates="request")


class Repairs(Base):
    __tablename__ = "repairs"

    id = Column(Integer, primary_key=True)
    worker_id = Column(Integer, ForeignKey("workers.id"), nullable=False)
    request_id = Column(Integer, ForeignKey("requests.id"), nullable=False)
    repair_status = Column(String(50), nullable=False)
    repair_type = Column(String(50), nullable=False)
    costs = Column(Float, nullable=False)
    repair_date = Column(Date, nullable=False)

    worker = relationship("Workers", back_populates="repairs")
    request = relationship("Requests", back_populates="repairs")
