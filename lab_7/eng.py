from sqlalchemy import create_engine
from models import Base

DATABASE_URL = "postgresql+psycopg2://nisu:1234@localhost:5432/autoservice"

def get_db_engine():
    engine = create_engine(DATABASE_URL)

    Base.metadata.create_all(engine)
    return engine