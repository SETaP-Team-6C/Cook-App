from os import remove
from sqlite3 import connect
from sqlite3 import Row
from pathlib import Path

from main.paths import PROJECT_MAIN, PROJECT_ROOT


class Database:
    def __init__(self, app):
        self.is_testing = app.config.get('TESTING', False)

        if self.is_testing:
            if not Path(self.get_database_path()).exists():
                self.create_new_database()

        else:
            if not Path(self.get_database_path()).exists():
                self.create_new_database()

    def __enter__(self):
        self.con = connect(self.get_database_path())
        self.con.execute("PRAGMA foreign_keys = 1")
        self.con.row_factory = Row
        return self.con

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.con.close()

    def create_new_database(self):
        with self as con:
            cur = con.cursor()

            with open(self.get_database_schema()) as schema:
                sql = schema.read()
                cur.executescript(sql)

            with open(self.get_database_test_data()) as test_data:
                sql = test_data.read()
                cur.executescript(sql)

    def get_database_path(self):
        if self.is_testing:
            return PROJECT_MAIN / "test_database.db"

        return PROJECT_MAIN / "database.db"

    @staticmethod
    def delete_test_database():
        test_db = PROJECT_MAIN / "test_database.db"
        if Path(test_db).exists():
            remove(test_db)

    @staticmethod
    def get_database_schema():
        return PROJECT_ROOT / "database/schema.sql"

    @staticmethod
    def get_database_test_data():
        return PROJECT_ROOT / "database/test_data.sql"