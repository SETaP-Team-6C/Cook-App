from sqlite3 import connect
from sqlite3 import Connection
from sqlite3 import Row
from pathlib import Path

from main.paths import PROJECT_ROOT
from main.paths import PROJECT_MAIN


class Database:
    def __init__(self) -> None:
        if not Path(self.get_database_path()).exists():
            self.create_new_database()

    def create_new_database(self) -> None:
        with self.get_connection() as con:
            cur = con.cursor()

            with open(self.get_database_schema()) as schema:
                sql = schema.read()
                cur.executescript(sql)

            with open(self.get_database_test_data()) as test_data:
                sql = test_data.read()
                cur.executescript(sql)



    def get_connection(self) -> Connection:
        con = connect(self.get_database_path())
        con.row_factory = Row
        return con


    @staticmethod
    def get_database_path() -> str:
        return PROJECT_MAIN / "database.db"

    @staticmethod
    def get_database_schema() -> str:
        return PROJECT_ROOT / "database/schema.sql"

    @staticmethod
    def get_database_test_data() -> str:
        return PROJECT_ROOT / "database/test_data.sql"
