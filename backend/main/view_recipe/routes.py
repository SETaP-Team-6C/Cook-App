from flask import blueprints
from flask import request
from flask import abort

from main.database import Database
from main.paths import PROJECT_MAIN

view_recipe_bp = blueprints.Blueprint('view-recipe',__name__)

@view_recipe_bp.route('/view-recipe',methods=['GET'])
def view_recipe():
    recipe_id = request.args.get('recipe_id')
    user_id = request.args.get("user_id")

    if recipe_id is None:
        abort(400)

    if user_id is None:
        abort(400)

    db = Database()

    with db.get_connection() as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "view_recipe/sql/get_recipe.sql",'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql,(user_id,recipe_id))

        rows= cur.fetchall()

        if len(rows) == 0:
            abort(404)

        title = rows[0][0]
        time = rows[0][1]
        difficulty = rows[0][2]

        steps_dic = {}
        ingredient_dic = {}
        completed_steps = []


        for row in rows:
            step_id = row[3]
            step_index = row[4]
            step_desc = row[5]
            step_duration = row[6]
            step_completed = row[7]

            ingredient_id = row[8]
            ingredient_name = row[9]
            ingredient_amount = row[10]
            ingredient_unit = row[11]
            ingredient_calories = row[12]

            if step_id is not None and step_id not in steps_dic:
                steps_dic[step_id] = {
                    "recipe_step_id": step_id,
                    "recipe_step_index": step_index,
                    "recipe_step_description": step_desc,
                    "recipe_step_duration":  step_duration
                }

                if step_completed is not None:
                    completed_steps.append(step_id)

            if ingredient_id is not None and ingredient_id not in ingredient_dic:
                ingredient_dic[ingredient_id] = {
                    "recipe_ingredient_id": ingredient_id,
                    "recipe_ingredient_name": ingredient_name,
                    "recipe_ingredient_amount": ingredient_amount,
                    "recipe_ingredient_unit": ingredient_unit,
                    "recipe_ingredient_calories": ingredient_calories
                }

        steps = list(steps_dic.values())

        #need to change
        steps.sort(key=lambda x: int(x["recipe_step_index"]) if x["recipe_step_index"].isdigit() else x["recipe_step_index"])

        ingredients = list(ingredient_dic.values())

        return {
            "recipe_title": title,
            "recipe_time": time,
            "recipe_difficulty": difficulty,
            "steps": steps,
            "ingredients": ingredients,
            "completed_steps": completed_steps
        }

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


