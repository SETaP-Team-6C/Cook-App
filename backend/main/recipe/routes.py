import re
from flask import blueprints, current_app
from flask import request
from flask import abort
from flask import Response
from flask import session
import json

from main.database import Database
from main.paths import PROJECT_MAIN

recipe_bp = blueprints.Blueprint('recipes', __name__)

ALLOWED_EXTENSIONS = {"png", "jpg","jpeg","webp"}
MAX_FILE_SIZE = 5 * 1024 * 1024;

def allowed_file(filename):
    return "." in filename and \
            filename.rsplit(".",1)[1].lower() in ALLOWED_EXTENSIONS


# Magic byte signatures so a renamed non-image file is still rejected
IMAGE_SIGNATURES = (
    b"\xff\xd8\xff",       # jpg / jpeg
    b"\x89PNG\r\n\x1a\n",  # png
)

def is_image(data):
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":  # webp
        return True
    return any(data.startswith(sig) for sig in IMAGE_SIGNATURES)


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
    if "user_id" not in session:
        abort(401, "authentication required")

    #getting fields form data
    try:
        recipe_title = request.form.get("recipe-title")
        recipe_time = request.form.get("recipe-time")
        recipe_difficulty = request.form.get("recipe-difficulty")

        recipe_ingredients = json.loads(request.form.get("recipe-ingredients","[]"))
        recipe_steps = json.loads(request.form.get("recipe-steps","[]"))
    except (json.JSONDecodeError, TypeError) as error:
        abort(400, f"invalid json in data : {str(error)}")

    #validate data
    if not recipe_title:
        abort(400, "recipe title is required")
    if not recipe_steps:
        abort(400, "recipe steps is required")
    if not recipe_difficulty:
        abort(400, "recipe difficulty is required")
    if not recipe_time:
        abort(400, "recipe time is required")
    if not recipe_ingredients:
        abort(400, "recipe ingredients is required")

    #validate ingredients
    for ingredient in recipe_ingredients:
        if "ingredient-amount" not in ingredient:
            abort(400, "ingredient amount is required")

        if not isinstance(ingredient["ingredient-amount"],int):
            abort(400, "ingredient amount must be int")

        if "ingredient-calories" not in ingredient:
            abort(400, "ingredient amount is required")

        if not isinstance(ingredient["ingredient-calories"],int):
            abort(400, "ingredient calories must be int")

        if "ingredient-name" not in ingredient:
            abort(400, "ingredient name is required")

        if "ingredient-unit" not in ingredient:
            abort(400, "ingredient unit is required")

    #validate steps
    for step in recipe_steps:
        if "step-description" not in step:
            abort(400, "step desc is required")
        if "step-duration" not in step:
            abort(400, "step duration is required")
        if "step-index" not in step:
            abort(400, "step index is required")

    #handle main image
    main_image_blob = None
    if "recipe-main-image" in request.files:
        file = request.files["recipe-main-image"]
        if file and file.filename:
            if not allowed_file(file.filename):
                abort(400, "main image must be a png, jpg, jpeg or webp file")
            image_data = file.read()
            if len(image_data) > MAX_FILE_SIZE:
                abort(400, "image too big max is 5mb")
            if not is_image(image_data):
                abort(400, "main image file is not a valid image")
            main_image_blob = image_data

    # step images
    step_images = {}
    for key in request.files:
        if key.startswith("step-image-"):
            step_index = key.replace("step-image-","")
            file = request.files[key]
            if file and file.filename:
                if not allowed_file(file.filename):
                    abort(400, f"step image {step_index} must be a png, jpg, jpeg or webp file")
                image_data = file.read()
                if len(image_data) > MAX_FILE_SIZE:
                    abort(400, f"step image {step_index} file too big 5mb max")
                if not is_image(image_data):
                    abort(400, f"step image {step_index} is not a valid image")
                step_images[step_index] = image_data
        

    with Database(current_app) as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "recipe/sql/add_recipe.sql", 'r') as sql_file:
            sql = sql_file.read()
            #change this
            cur.execute(sql, (recipe_title, recipe_time, recipe_difficulty,main_image_blob))

        new_recipe_id = cur.lastrowid

        #insert ingredients
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
            step_image_blob = step_images.get(step_index, None)

            with open(PROJECT_MAIN / "recipe/sql/add_step.sql", 'r') as sql_file:
                sql = sql_file.read()
                cur.execute(sql, (new_recipe_id, step_index, step_description, step_duration, step_image_blob))
        con.commit()

    return {"recipe-id": new_recipe_id}, 201

# get main image
@recipe_bp.route("/recipe-image/<int:recipe_id>")
def get_recipe_image(recipe_id):
    with Database(current_app) as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "recipe/sql/get_main_image.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (recipe_id,))
            result = cur.fetchone()

            if result is None or result["recipe_main_image"] is None:
                abort(404, "image not found")

            response = Response(result["recipe_main_image"], mimetype="image/jpeg")
            response.headers["Cache-Control"] = "public, max-age=31536000" #cache for a whole year
            return response

# get step image 
@recipe_bp.route("/step-image/<int:step_id>")
def get_step_image(step_id):
    with Database(current_app) as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "recipe/sql/get_step_image.sql", 'r') as sql_file:
            sql = sql_file.read()
            cur.execute(sql, (step_id,))
            result = cur.fetchone()

            if result is None or result["recipe_step_image"] is None:
                abort(404, "image not found")

            response = Response(result["recipe_step_image"], mimetype="image/jpeg")
            response.headers["Cache-Control"] = "public, max-age=31536000" #cache for a whole year
            return response
