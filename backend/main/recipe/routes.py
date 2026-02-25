from flask import blueprints

from main.database import Database
from main.paths import PROJECT_MAIN

recipe_bp = blueprints.Blueprint('recipes', __name__)

@recipe_bp.route('/get-recipes')
def get_recipes():
    db = Database()
    with db.get_connection() as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "recipe/sql/get_recipes.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql)

        data = cur.fetchall()

    recipes = []
    for row in data:
        recipes.append(dict(row))

    return {
        "recipes": recipes
    }

