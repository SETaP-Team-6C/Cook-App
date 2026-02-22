from flask import Flask

from backend.database import Database
from recipe.routes import recipe_bp
from authentication.routes import authentication_bp

app = Flask(__name__)
app.register_blueprint(recipe_bp)
app.register_blueprint(authentication_bp)

database = Database()

@app.route('/')
def index():
    return {
        "Message": "Hello World!"
    }
