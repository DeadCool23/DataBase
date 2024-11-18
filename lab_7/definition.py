import eng
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker

def count_repairs_by_status(session, status):
    query = text("""
        SELECT w.first_name || ' ' || w.last_name AS worker_name, COUNT(*) AS repair_count
        FROM repairs r
        JOIN workers w ON r.worker_id = w.id
        WHERE r.repair_status = :status
        GROUP BY w.id
    """)
    
    result = session.execute(query, {"status": status})
    return [(row[0], row[1]) for row in result]

engine = eng.get_db_engine()
Session = sessionmaker(bind=engine)
session = Session()

status = "Ремонтируется"
repairs = count_repairs_by_status(session, status)

for worker_name, repair_count in repairs:
    print(f"Работник: {worker_name}, Кол-во ремонтов: {repair_count}")
