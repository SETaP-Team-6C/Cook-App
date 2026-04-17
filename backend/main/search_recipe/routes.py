from main.account.routes import account_bp
from flask import blueprints
from flask import request
from flask import abort


from main.database import Database
from main.paths import PROJECT_MAIN

search_bp = blueprints.Blueprint('search',__name__)

@search_bp.route('/search-recipe',methods=['GET'])
def search_recipe():
    query = request.args.get('q','').strip()

    if not query:
        abort(400)

    db = Database()

    with db.get_connection() as con:
        cur = con.cursor()
        with open(PROJECT_MAIN / "search_recipe/sql/search_recipe.sql",'r') as sql_file:
           sql = sql_file.read() 
           cur.execute(sql,(f"%{query}%",))

        data = cur.fetchall()

    recipes = []
    for row in data:
        recipes.append(dict(row))

    return {"recipes": recipes}


    
