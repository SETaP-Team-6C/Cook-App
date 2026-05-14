import json

from flask.testing import FlaskClient

from tests.conftest import client


def test_get_recipes(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    }
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200

    body = {
        "recipe-ingredients": json.dumps([
            {
                "ingredient-name": "Ingredient 1",
                "ingredient-amount": 300,
                "ingredient-unit": "g",
                "ingredient-calories": 500
            },
            {
                "ingredient-name": "Ingredient 2",
                "ingredient-amount": 400,
                "ingredient-unit": "g",
                "ingredient-calories": 700
            }
        ]),
        "recipe-title": "Test Recipe",
        "recipe-steps": json.dumps([
            {
                "step-description": "Step 1",
                "step-duration": "PT30M",
                "step-index": "1"
            },
            {
                "step-description": "Step 2",
                "step-duration": "PT45M",
                "step-index": "2"
            }
        ]),
        "recipe-difficulty": "medium",
        "recipe-time": "PT1H30M"
    }
    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    assert response.status_code == 201
    assert response.mimetype == "application/json"

    response = client.get('/get-recipes')
    assert response.status_code == 200
    assert response.mimetype == "application/json"
    assert response.json == ({
        "recipes": [
            {
                "recipe_id": 1,
                "recipe_title": "Test Recipe"
            }
        ]
    })


def test_no_recipes(client):
    response = client.get('/get-recipes')
    assert response.status_code == 200
    assert response.mimetype == "application/json"
    assert response.json == ({
        "recipes": [
        ]
    })
