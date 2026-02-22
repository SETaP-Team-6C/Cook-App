from pathlib import Path

from flask import blueprints

from backend.database import Database

recipe_bp = blueprints.Blueprint('recipes', __name__)

@recipe_bp.route('/get-recipes')
def get_recipes():
    db = Database()
    with db.get_connection() as con:
        cur = con.cursor()
        with open(Path('recipe/sql/get_recipes.sql').absolute(), 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql)

        data = cur.fetchall()

    recipes = []
    for row in data:
        recipes.append(dict(row))

    return {
        "recipes": recipes
    }

