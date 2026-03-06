from flask import blueprints
from flask import request
from flask import abort

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


@recipe_bp.route('/add-recipe', methods=['POST'])
def add_recipe():
    # We are using content-type: application/json for this endpoint!
    print(request.content_type)


    # db = Database()
    # with db.get_connection() as con:
    #     cur = con.cursor()
    #     with open(PROJECT_MAIN / "recipe/sql/add_recipe.sql", 'r') as sql_file:
    #         sql = sql_file.read()
    #         cur.execute(sql, (recipe_title, recipe_time, recipe_calories))
    #
    #     new_recipe_id = cur.lastrowid
