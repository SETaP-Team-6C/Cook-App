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

def test_search_recipe_partial_query_returns_only_matching_results(client):
    # Authenticate
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456"
    }
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200

    # Add two recipes, one titled 'test recipe' and one 'different recipe'
    for title in ["test recipe", "different recipe"]:
        data = {
            "recipe-ingredients": json.dumps([
                {"ingredient-name": "Ingredient", "ingredient-amount": 50, "ingredient-unit": "g", "ingredient-calories": 10}
            ]),
            "recipe-title": title,
            "recipe-steps": json.dumps([
                {"step-description": "Step 1", "step-duration": "PT5M", "step-index": "1"}
            ]),
            "recipe-difficulty": "easy",
            "recipe-time": "PT10M"
        }
        resp = client.post('/add-recipe', data=data, content_type="multipart/form-data")
        assert resp.status_code == 201

    # Search for 'test' should return only 'test recipe'
    response = client.get('/search-recipe?q=test')
    assert response.status_code == 200
    resp_json = response.get_json()
    assert 'recipes' in resp_json
    titles = [r['recipe_title'] for r in resp_json['recipes']]
    assert any(t.lower() == 'test recipe' for t in titles)
    assert all(('different' not in t.lower() or 'test' in t.lower()) for t in titles)


def test_partial_match(client):
    # Authenticate
    body = {"user_fname": "test", "user_lname": "user", "user_password": "123456"}
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200

    # Add Chicken Soup, Vegetable Soup, Fried Rice
    for title in ["Chicken Soup", "Vegetable Soup", "Fried Rice"]:
        data = {
            "recipe-ingredients": json.dumps([
                {"ingredient-name": "Ingredient", "ingredient-amount": 10, "ingredient-unit": "g", "ingredient-calories": 5}
            ]),
            "recipe-title": title,
            "recipe-steps": json.dumps([
                {"step-description": "Do it", "step-duration": "PT5M", "step-index": "1"}
            ]),
            "recipe-difficulty": "easy",
            "recipe-time": "PT10M"
        }
        resp = client.post('/add-recipe', data=data, content_type="multipart/form-data")
        assert resp.status_code == 201

    # Search for 'soup' should match both soups
    response = client.get('/search-recipe?q=soup')
    assert response.status_code == 200
    resp_json = response.get_json()
    titles = [r['recipe_title'] for r in resp_json['recipes']]
    assert 'Chicken Soup' in titles
    assert 'Vegetable Soup' in titles
    assert 'Fried Rice' not in titles


def test_get_recipes(client):
    # Authenticate
    body = {"user_fname": "test", "user_lname": "user", "user_password": "123456"}
    response = client.post("/authenticate", data=body)
    assert response.status_code == 200

    # Add a recipe titled Test Recipe
    data = {
        "recipe-ingredients": json.dumps([
            {"ingredient-name": "Ingredient", "ingredient-amount": 10, "ingredient-unit": "g", "ingredient-calories": 5}
        ]),
        "recipe-title": "Test Recipe",
        "recipe-steps": json.dumps([
            {"step-description": "Do it", "step-duration": "PT5M", "step-index": "1"}
        ]),
        "recipe-difficulty": "easy",
        "recipe-time": "PT10M"
    }
    resp = client.post('/add-recipe', data=data, content_type="multipart/form-data")
    assert resp.status_code == 201

    # Call get-recipes
    response = client.get('/get-recipes')
    assert response.status_code == 200
    resp_json = response.get_json()
    assert resp_json == {"recipes": [{"recipe_id": 1, "recipe_title": "Test Recipe"}]}


def test_no_recipes(client):
    # Ensure no recipes exist; conftest fixture resets DB per test
    response = client.get('/get-recipes')
    assert response.status_code == 200
    assert response.get_json() == {"recipes": []}

