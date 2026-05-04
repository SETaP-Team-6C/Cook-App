from flask import blueprints, current_app
from flask import request
from flask import abort


from main.database import Database
from main.paths import PROJECT_MAIN

SEARCH_SQL = (PROJECT_MAIN / "search_recipe/sql/search_recipe.sql").read_text()
INGREDIENT_SQL = (PROJECT_MAIN / "search_recipe/sql/recipe_ingredients.sql").read_text()

search_bp = blueprints.Blueprint('search',__name__)

@search_bp.route('/search-recipe',methods=['GET'])
def search_recipe():
    query = request.args.get('q','').strip()

    if not query:
        abort(400)


    with Database(current_app) as con:
        cur = con.cursor()
        cur.execute(SEARCH_SQL,(f"%{query}%",))

        recipe_rows = cur.fetchall()

        recipes = []


        for recipe in recipe_rows:
            recipe_dict = dict(recipe)
            recipe_id = recipe["recipe_id"]

            cur.execute(INGREDIENT_SQL, (recipe_id,))

            ingredient_rows = cur.fetchall()
            ingredients = []

            for ingredient in ingredient_rows:
                ingredients.append(dict(ingredient))


            recipe_dict["ingredients"] = ingredients


            recipes.append(recipe_dict)

    return {"recipes": recipes}


    
