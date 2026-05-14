import json

from werkzeug.datastructures import FileStorage

from main.paths import PROJECT_ROOT


def _authenticate(client):
    response = client.post("/authenticate", data={
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    })
    assert response.status_code == 200
    return response.get_json()["user"]["user_id"]


def _add_simple_recipe(client, title="Test Recipe"):
    body = {
        "recipe-ingredients": json.dumps([
            {"ingredient-name": "Egg", "ingredient-amount": 2, "ingredient-unit": "unit", "ingredient-calories": 140}
        ]),
        "recipe-title": title,
        "recipe-steps": json.dumps([
            {"step-description": "Step 1", "step-duration": "PT10M", "step-index": "1"}
        ]),
        "recipe-difficulty": "easy",
        "recipe-time": "PT10M"
    }
    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    assert response.status_code == 201
    return response.get_json()["recipe-id"]


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



def test_view_recipe_with_user_id_steps_uncompleted(client):
    user_id = _authenticate(client)
    recipe_id = _add_simple_recipe(client)

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    assert response.status_code == 200
    steps = response.get_json()["recipe-steps"]
    assert len(steps) == 1
    assert steps[0]["step-completion"] == False


def test_complete_step(client):
    user_id = _authenticate(client)
    recipe_id = _add_simple_recipe(client)

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    step_id = response.get_json()["recipe-steps"][0]["recipe-step-id"]

    response = client.post('/complete-step', json={"recipe_step_id": step_id, "user_id": user_id})
    assert response.status_code == 200
    assert response.get_json()["success"] == True

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    assert response.get_json()["recipe-steps"][0]["step-completion"] == True


def test_uncomplete_step(client):
    user_id = _authenticate(client)
    recipe_id = _add_simple_recipe(client)

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    step_id = response.get_json()["recipe-steps"][0]["recipe-step-id"]

    client.post('/complete-step', json={"recipe_step_id": step_id, "user_id": user_id})

    response = client.post('/uncomplete-step', json={"recipe_step_id": step_id, "user_id": user_id})
    assert response.status_code == 200
    assert response.get_json()["success"] == True

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    assert response.get_json()["recipe-steps"][0]["step-completion"] == False


def test_complete_step_twice(client):
    user_id = _authenticate(client)
    recipe_id = _add_simple_recipe(client)

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    step_id = response.get_json()["recipe-steps"][0]["recipe-step-id"]

    client.post('/complete-step', json={"recipe_step_id": step_id, "user_id": user_id})
    response = client.post('/complete-step', json={"recipe_step_id": step_id, "user_id": user_id})
    assert response.status_code == 200

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    assert response.get_json()["recipe-steps"][0]["step-completion"] == True


def test_uncomplete_step_not_completed(client):
    user_id = _authenticate(client)
    recipe_id = _add_simple_recipe(client)

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    step_id = response.get_json()["recipe-steps"][0]["recipe-step-id"]

    response = client.post('/uncomplete-step', json={"recipe_step_id": step_id, "user_id": user_id})
    assert response.status_code == 200
    assert response.get_json()["success"] == True

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    assert response.get_json()["recipe-steps"][0]["step-completion"] == False


def test_complete_step_missing_recipe_step_id(client):
    user_id = _authenticate(client)
    response = client.post('/complete-step', json={"user_id": user_id})
    assert response.status_code == 400


def test_complete_step_missing_user_id(client):
    _authenticate(client)
    response = client.post('/complete-step', json={"recipe_step_id": 1})
    assert response.status_code == 400


def test_uncomplete_step_missing_recipe_step_id(client):
    user_id = _authenticate(client)
    response = client.post('/uncomplete-step', json={"user_id": user_id})
    assert response.status_code == 400


def test_uncomplete_step_missing_user_id(client):
    _authenticate(client)
    response = client.post('/uncomplete-step', json={"recipe_step_id": 1})
    assert response.status_code == 400


def test_view_recipe_multiple_steps_partial_completion(client):
    user_id = _authenticate(client)

    body = {
        "recipe-ingredients": json.dumps([
            {"ingredient-name": "Tomato", "ingredient-amount": 2, "ingredient-unit": "unit", "ingredient-calories": 40}
        ]),
        "recipe-title": "Tomato Soup",
        "recipe-steps": json.dumps([
            {"step-description": "Chop tomatoes", "step-duration": "PT5M", "step-index": "1"},
            {"step-description": "Cook tomatoes", "step-duration": "PT15M", "step-index": "2"}
        ]),
        "recipe-difficulty": "easy",
        "recipe-time": "PT20M"
    }
    response = client.post('/add-recipe', data=body, content_type="multipart/form-data")
    recipe_id = response.get_json()["recipe-id"]

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    steps = response.get_json()["recipe-steps"]
    step_1_id = steps[0]["recipe-step-id"]

    client.post('/complete-step', json={"recipe_step_id": step_1_id, "user_id": user_id})

    response = client.get(f"/view-recipe/{recipe_id}?user_id={user_id}")
    steps = response.get_json()["recipe-steps"]
    assert steps[0]["step-completion"] == True
    assert steps[1]["step-completion"] == False


def test_recipe_image_no_image(client):
    _authenticate(client)
    recipe_id = _add_simple_recipe(client)

    response = client.get(f"/recipe-image/{recipe_id}")
    assert response.status_code == 404


def test_step_image_not_found(client):
    response = client.get("/step-image/99999")
    assert response.status_code == 404


def test_step_no_image(client):
    _authenticate(client)
    recipe_id = _add_simple_recipe(client)

    response = client.get(f"/view-recipe/{recipe_id}")
    step_id = response.get_json()["recipe-steps"][0]["recipe-step-id"]

    response = client.get(f"/step-image/{step_id}")
    assert response.status_code == 404


def test_view_recipe_nonexistent_id(client):
    _authenticate(client)
    response = client.get("/view-recipe/99999")
    assert response.status_code == 404


def test_view_recipe_unauthenticated(client):
    response = client.get("/view-recipe/1")
    assert response.status_code == 401


def test_complete_step_unauthenticated(client):
    response = client.post('/complete-step', json={"recipe_step_id": 1, "user_id": 1})
    assert response.status_code == 401


def test_uncomplete_step_unauthenticated(client):
    response = client.post('/uncomplete-step', json={"recipe_step_id": 1, "user_id": 1})
    assert response.status_code == 401


def test_complete_step_malformed_json(client):
    _authenticate(client)
    response = client.post('/complete-step', data="not-json", content_type="application/json")
    assert response.status_code == 400


def test_uncomplete_step_malformed_json(client):
    _authenticate(client)
    response = client.post('/uncomplete-step', data="not-json", content_type="application/json")
    assert response.status_code == 400


def test_step_image(client):
    _authenticate(client)
    image_path = PROJECT_ROOT / "tests/assets/test_image.jpg"

    with open(image_path, "rb") as f:
        image = FileStorage(stream=f, filename="test_image.jpg", content_type="image/jpeg")
        body = {
            "step-image-1": image,
            "recipe-ingredients": json.dumps([
                {"ingredient-name": "Pasta", "ingredient-amount": 300, "ingredient-unit": "g", "ingredient-calories": 400}
            ]),
            "recipe-title": "Pasta Dish",
            "recipe-steps": json.dumps([
                {"step-description": "Cook pasta", "step-duration": "PT15M", "step-index": "1"}
            ]),
            "recipe-difficulty": "easy",
            "recipe-time": "PT15M"
        }
        response = client.post('/add-recipe', data=body, content_type="multipart/form-data")

    assert response.status_code == 201
    recipe_id = response.get_json()["recipe-id"]

    response = client.get(f"/view-recipe/{recipe_id}")
    step_id = response.get_json()["recipe-steps"][0]["recipe-step-id"]

    with open(image_path, "rb") as f:
        expected_data = f.read()

    response = client.get(f"/step-image/{step_id}")
    assert response.status_code == 200
    assert response.data == expected_data
    assert response.mimetype == "image/jpeg"
