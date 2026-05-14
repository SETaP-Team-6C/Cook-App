import json

from werkzeug.datastructures import FileStorage

from main.paths import PROJECT_ROOT


def test_view_recipe(client):
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
    recipe_id = response.get_json()["recipe-id"]

    response = client.get(f"/view-recipe/{recipe_id}")
    assert response.status_code == 200
    assert response.mimetype == "application/json"
    assert (response.get_json() ==
        {
            "recipe-id": recipe_id,
            "recipe-ingredients": [
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
            ],
            "recipe-title": "Test Recipe",
            "recipe-steps": [
                {
                    "recipe-step-id": 1,
                    "step-completion": False,
                    "step-description": "Step 1",
                    "step-duration": "PT30M",
                    "step-index": "1"
                },
                {
                    "recipe-step-id": 2,
                    "step-completion": False,
                    "step-description": "Step 2",
                    "step-duration": "PT45M",
                    "step-index": "2"
                }
            ],
            "recipe-difficulty": "medium",
            "recipe-time": "PT1H30M"
        })

def test_recipe_image(client):
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    }
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200

    image_path = PROJECT_ROOT / "tests/assets/test_image.jpg"
    image = FileStorage(
        stream=open(image_path, "rb"),
        filename="test_image.jpg",
        content_type="image/jpeg"
    )

    body = {
        "recipe-main-image": image,
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
    recipe_id = response.get_json()["recipe-id"]

    image = FileStorage(
        stream=open(image_path, "rb"),
        filename="test_image.jpg",
        content_type="image/jpeg"
    )
    response = client.get(f"/recipe-image/{recipe_id}")
    assert response.status_code == 200
    assert response.data == image.stream.read()
    assert response.mimetype == "image/jpeg"


def test_view_non_existent_recipe(client):
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    }
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200

    response = client.get(f"/view-recipe/99")
    assert response.status_code == 404


def test_non_existent_image(client):
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    }
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200

    image_path = PROJECT_ROOT / "tests/assets/test_image.jpg"
    image = FileStorage(
        stream=open(image_path, "rb"),
        filename="test_image.jpg",
        content_type="image/jpeg"
    )

    body = {
        "recipe-main-image": image,
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
    recipe_id = response.get_json()["recipe-id"]

    image = FileStorage(
        stream=open(image_path, "rb"),
        filename="test_image.jpg",
        content_type="image/jpeg"
    )
    response = client.get(f"/recipe-image/{recipe_id}")
    assert response.status_code == 200
    assert response.data == image.stream.read()
    assert response.mimetype == "image/jpeg"

    response = client.get(f"/recipe-image/{recipe_id + 1}")
    assert response.status_code == 404
