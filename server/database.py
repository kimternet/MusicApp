from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

load_dotenv()

def get_env_variable(name):
    value = os.getenv(name)
    if value is None:
        raise ValueError(f"env variable {name} is not set")
    return value

DB_USER = get_env_variable("DB_USER")
DB_PASSWORD = get_env_variable("DB_PASSWORD")
DB_HOST = get_env_variable("DB_HOST")
DB_PORT = get_env_variable("DB_PORT")
DB_NAME = get_env_variable("DB_NAME")

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

try:
    engine = create_engine(DATABASE_URL)
    # 연결 테스트
    with engine.connect() as connection:
        print("db connected")
except SQLAlchemyError as e:
    print(f"db connection error: {e}")


SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()