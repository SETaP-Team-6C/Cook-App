import io
import json

from werkzeug.datastructures import FileStorage


def _authenticate(client):
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    }
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200


def _recipe_body():
    return {
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


def test_add_recipe(client):
    _authenticate(client)

    response = client.post('/add-recipe', data=_recipe_body(), content_type="multipart/form-data")
    assert response.status_code == 201
    assert response.mimetype == "application/json"
    assert response.get_json()["recipe-id"] == 1


def test_no_ingredients(client):
    _authenticate(client)

    body = _recipe_body()
    del body["recipe-ingredients"]

    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    assert response.status_code == 400


def test_no_steps(client):
    _authenticate(client)

    body = _recipe_body()
    del body["recipe-steps"]

    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    assert response.status_code == 400


def test_no_title(client):
    _authenticate(client)

    body = _recipe_body()
    del body["recipe-title"]

    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    assert response.status_code == 400


def test_unauthenticated(client):
    response = client.post('/add-recipe', data=_recipe_body(), content_type="multipart/form-data")
    assert response.status_code == 401


def test_file_upload_limit(client):
    _authenticate(client)

    body = _recipe_body()
    # 17 MB exceeds the app's 16 MB MAX_CONTENT_LENGTH limit
    body["recipe-main-image"] = FileStorage(
        stream=io.BytesIO(b"\0" * (17 * 1000 * 1000)),
        filename="big.jpg",
        content_type="image/jpeg"
    )

    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    assert response.status_code == 413


def test_non_image_file(client):
    _authenticate(client)

    body = _recipe_body()
    # Allowed extension, but the bytes are not a real image
    body["recipe-main-image"] = FileStorage(
        stream=io.BytesIO(b"this is definitely not a real image file" * 20),
        filename="random.jpg",
        content_type="image/jpeg"
    )

    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    assert response.status_code == 400
