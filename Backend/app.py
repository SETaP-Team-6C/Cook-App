from flask import Flask

from Backend.database import Database

app = Flask(__name__)

database = Database()

@app.route("/")
def index():
    return {
        "Message": "Hello World!"
    }
