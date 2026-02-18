from flask import Flask

from database import Database
from recipe.routes import recipe_bp

app = Flask(__name__)
app.register_blueprint(recipe_bp)

database = Database()

@app.route('/')
def index():
    return {
        "Message": "Hello World!"
    }
