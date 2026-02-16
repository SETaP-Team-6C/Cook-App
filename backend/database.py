from sqlite3 import connect
from sqlite3 import Connection
from pathlib import Path


class Database:
    def __init__(self) -> None:
        if not self.get_database_path().exists():
            self.create_new_database()

    def create_new_database(self) -> None:
        with self.get_connection() as con:
            cur = con.cursor()

            with open(self.get_database_schema().absolute()) as schema:
                sql = schema.read()
                cur.executescript(sql)

            with open(self.get_database_test_data().absolute()) as test_data:
                sql = test_data.read()
                cur.executescript(sql)



    def get_connection(self) -> Connection:
        return connect(self.get_database_path())

    @staticmethod
    def get_database_path() -> Path:
        return Path('database.db')

    @staticmethod
    def get_database_schema() -> Path:
        return Path('../database/schema.sql')

    @staticmethod
    def get_database_test_data() -> Path:
        return Path('../database/test_data.sql')
