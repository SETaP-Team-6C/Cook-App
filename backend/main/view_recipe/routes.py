from flask import blueprints
from flask import request
from flask import abort

from main.database import Database
from main.paths import PROJECT_MAIN

view_recipe_bp = blueprints.Blueprint('view-recipe',__name__)

@view_recipe_bp.route('/view-recipe/<int:recipe_id>',methods=['GET'])
def view_recipe(recipe_id):
    db = Database()
    with db.get_connection() as con:
        cur = con.cursor()

        with open(PROJECT_MAIN / "view_recipe/sql/get_recipe.sql") as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (recipe_id,))
            recipe = dict(cur.fetchone())

        if len(recipe) == 0:
            return "", 404

        with open(PROJECT_MAIN / "view_recipe/sql/get_recipe_ingredients.sql") as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (recipe_id,))
            ingredient_data = cur.fetchall()

        ingredients = []
        for row in ingredient_data:
            ingredients.append(dict(row))

        with open(PROJECT_MAIN / "view_recipe/sql/get_recipe_steps.sql") as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (recipe_id,))
            step_data = cur.fetchall()

        steps = []
        for row in step_data:
            steps.append(dict(row))

        recipe["recipe-ingredients"] = ingredients
        recipe["recipe-steps"] = steps

        return recipe

@view_recipe_bp.route('/complete-step',methods=["POST"])
def complete_step():

    data = request.get_json()
    recipe_step_id = data.get("recipe_step_id")
    user_id = data.get("user_id")

    if recipe_step_id is None or user_id is None:
        abort(400)

    db = Database()
    with db.get_connection() as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "view_recipe/sql/complete_step.sql",'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql,(recipe_step_id,user_id))

            con.commit()

    return {"success": True},200


@view_recipe_bp.route('/uncomplete-step',methods=["POST"])
def uncomplete_step():

    data = request.get_json()
    recipe_step_id = data.get("recipe_step_id")
    user_id = data.get("user_id")

    if recipe_step_id is None or user_id is None:
        abort(400)

    db = Database()
    with db.get_connection() as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "view_recipe/sql/uncomplete_step.sql",'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql,(recipe_step_id,user_id))

            con.commit()

    return {"success": True},200


