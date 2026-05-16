import json


def test_search_recipe(client):
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
    assert response.get_json()["recipe-id"] == 1

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
        "recipe-title": "Test Recipe 2",
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
    assert response.get_json()["recipe-id"] == 2

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
        "recipe-title": "Test Recipe 3",
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
    assert response.get_json()["recipe-id"] == 3

    response = client.get("/search-recipe?q=test%20recipe")
    assert response.status_code == 200
    assert response.mimetype == "application/json"
    assert response.get_json() == ({
        'recipes': [
            {
                'ingredients': [
                {
                    'recipe_ingredient_name': 'Ingredient 1'
                },
                {
                    'recipe_ingredient_name': 'Ingredient 2'
                }
            ],
                'recipe_difficulty': 'medium',
                'recipe_id': 1,
                'recipe_time': 'PT1H30M',
                'recipe_title': 'Test Recipe'
            },
            {
                'ingredients': [
                    {
                        'recipe_ingredient_name': 'Ingredient 1'
                    },
                    {
                        'recipe_ingredient_name': 'Ingredient 2'
                    }
                ],
                'recipe_difficulty': 'medium',
                'recipe_id': 2,
                'recipe_time': 'PT1H30M',
                'recipe_title': 'Test Recipe 2'
            },
            {
                'ingredients': [
                    {
                        'recipe_ingredient_name': 'Ingredient 1'
                    },
                    {
                        'recipe_ingredient_name': 'Ingredient 2'
                    }
                ],
                'recipe_difficulty': 'medium',
                'recipe_id': 3,
                'recipe_time': 'PT1H30M',
                'recipe_title': 'Test Recipe 3'
            }
        ]
    })
