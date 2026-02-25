from flask import Flask

from main.database import Database
from main.recipe.routes import recipe_bp
from main.authentication.routes import authentication_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.register_blueprint(recipe_bp)
    app.register_blueprint(authentication_bp)
    Database()

    return app

# todo: add index route
# @app.route('/')
# def index():
#     return {
#         "Message": "Hello World!"
#     }
