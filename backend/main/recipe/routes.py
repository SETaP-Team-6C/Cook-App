from flask import blueprints, current_app
from flask import request
from flask import abort
from flask import Response
from flask import session

from main.database import Database
from main.paths import PROJECT_MAIN

recipe_bp = blueprints.Blueprint('recipes', __name__)


@recipe_bp.route('/get-recipes')
def get_recipes():
    with Database(current_app) as con:
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
    #check if user is authenticated, todo: put user_id into the db
    if session.get("user_id", None) is None:
        abort(401)

    # We are using content-type: application/json for this endpoint!
    response = Response()
    response.headers['Accept'] = 'application/json'

    if not request.is_json:
        abort(415)

    data = request.get_json()

    if "recipe-ingredients" not in data:
        abort(400)

    if "recipe-title" not in data:
        abort(400)

    if "recipe-steps" not in data:
        abort(400)

    if "recipe-difficulty" not in data:
        abort(400)

    if "recipe-time" not in data:
        abort(400)

    if "recipe-steps" not in data:
        abort(400)

    recipe_ingredients = data['recipe-ingredients']
    recipe_title = data['recipe-title']
    recipe_steps = data['recipe-steps']
    recipe_difficulty = data['recipe-difficulty']
    recipe_time = data['recipe-time']

    for ingredient in recipe_ingredients:
        if "ingredient-amount" not in ingredient:
            abort(400)

        if not isinstance(ingredient["ingredient-amount"], int):
            abort(400)

        if "ingredient-calories" not in ingredient:
            abort(400)

        if not isinstance(ingredient["ingredient-calories"], int):
            abort(400)

        if "ingredient-name" not in ingredient:
            abort(400)

        if "ingredient-unit" not in ingredient:
            abort(400)

    for step in recipe_steps:
        if "step-description" not in step:
            abort(400)

        if "step-duration" not in step:
            # Consider validating for iso 8061?
            abort(400)

        if "step-index" not in step:
            abort(400)

    with Database(current_app) as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "recipe/sql/add_recipe.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (recipe_title, recipe_time, recipe_difficulty))

        new_recipe_id = cur.lastrowid

        for ingredient in recipe_ingredients:
            ingredient_amount = ingredient["ingredient-amount"]
            ingredient_calories = ingredient["ingredient-calories"]
            ingredient_name = ingredient["ingredient-name"]
            ingredient_unit = ingredient["ingredient-unit"]

            with open(PROJECT_MAIN / "recipe/sql/add_ingredient.sql", 'r') as sql_file:
                sql = sql_file.read()
                cur.execute(sql, (new_recipe_id, ingredient_name, ingredient_amount,
                                  ingredient_unit, ingredient_calories))

        for step in recipe_steps:
            step_description = step["step-description"]
            step_duration = step["step-duration"]
            step_index = step["step-index"]

            with open(PROJECT_MAIN / "recipe/sql/add_step.sql", 'r') as sql_file:
                sql = sql_file.read()
                cur.execute(sql, (new_recipe_id, step_index, step_description, step_duration))

    return {"recipe-id": new_recipe_id}, 201
