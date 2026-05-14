from flask import Flask

from main.account.routes import account_bp
from main.authentication.routes import authentication_bp
from main.database import Database
from main.index.routes import index_bp
from main.recipe.routes import recipe_bp
from main.search_recipe.routes import search_bp
from main.view_recipe.routes import view_recipe_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.secret_key = 'SECRET-KEY'
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1000 * 1000
    app.register_blueprint(recipe_bp)
    app.register_blueprint(authentication_bp)
    app.register_blueprint(index_bp)
    app.register_blueprint(account_bp)
    app.register_blueprint(search_bp)
    app.register_blueprint(view_recipe_bp)

    # Initialise db
    with Database(app) as _:
        pass

    return app
