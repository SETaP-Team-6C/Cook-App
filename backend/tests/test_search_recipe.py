import json


def _authenticate(client):
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    }
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200


def _add_recipe(client, title):
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
        "recipe-title": title,
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
    return response.get_json()["recipe-id"]


def test_search_recipe(client):
    _authenticate(client)
    assert _add_recipe(client, "Test Recipe") == 1
    assert _add_recipe(client, "Test Recipe 2") == 2
    assert _add_recipe(client, "Test Recipe 3") == 3

    response = client.get("/search-recipe?q=test%20recipe")
    assert response.status_code == 200
    assert response.mimetype == "application/json"
    assert response.get_json() == ({
        'recipes': [
            {
                'ingredients': [
                    {'recipe_ingredient_name': 'Ingredient 1'},
                    {'recipe_ingredient_name': 'Ingredient 2'}
                ],
                'recipe_difficulty': 'medium',
                'recipe_id': 1,
                'recipe_time': 'PT1H30M',
                'recipe_title': 'Test Recipe'
            },
            {
                'ingredients': [
                    {'recipe_ingredient_name': 'Ingredient 1'},
                    {'recipe_ingredient_name': 'Ingredient 2'}
                ],
                'recipe_difficulty': 'medium',
                'recipe_id': 2,
                'recipe_time': 'PT1H30M',
                'recipe_title': 'Test Recipe 2'
            },
            {
                'ingredients': [
                    {'recipe_ingredient_name': 'Ingredient 1'},
                    {'recipe_ingredient_name': 'Ingredient 2'}
                ],
                'recipe_difficulty': 'medium',
                'recipe_id': 3,
                'recipe_time': 'PT1H30M',
                'recipe_title': 'Test Recipe 3'
            }
        ]
    })


def test_case_sensitive_search(client):
    _authenticate(client)
    _add_recipe(client, "Test Recipe")
    _add_recipe(client, "Test Recipe 2")
    _add_recipe(client, "Test Recipe 3")

    # An upper-case query must still match the recipe titles
    response = client.get("/search-recipe?q=TEST%20RECIPE")
    assert response.status_code == 200

    titles = sorted(recipe["recipe_title"] for recipe in response.get_json()["recipes"])
    assert titles == ["Test Recipe", "Test Recipe 2", "Test Recipe 3"]


def test_partial_match(client):
    _authenticate(client)
    _add_recipe(client, "Test Recipe")
    _add_recipe(client, "Different Recipe")

    # "test" only appears in one of the two titles
    response = client.get("/search-recipe?q=test")
    assert response.status_code == 200

    titles = [recipe["recipe_title"] for recipe in response.get_json()["recipes"]]
    assert titles == ["Test Recipe"]
