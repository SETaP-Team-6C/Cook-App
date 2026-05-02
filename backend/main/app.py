from flask import Flask

from main.account.routes import account_bp
from main.database import Database
from main.recipe.routes import recipe_bp
from main.authentication.routes import authentication_bp
from main.index.routes import index_bp
from main.view_recipe.routes import view_recipe, view_recipe_bp
from main.search_recipe.routes import search_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.secret_key = 'SECRET-KEY'
    app.register_blueprint(recipe_bp)
    app.register_blueprint(authentication_bp)
    app.register_blueprint(index_bp)
    app.register_blueprint(account_bp)
    app.register_blueprint(search_bp)
    app.register_blueprint(view_recipe_bp)
    Database()

    return app
