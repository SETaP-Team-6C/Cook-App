from flask import blueprints

index_bp = blueprints.Blueprint('index', __name__)

@index_bp.route('/')
def index():
    return {
        "message": "Hello World!"
    }
