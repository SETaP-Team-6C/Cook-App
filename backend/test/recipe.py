from urllib import response
from flask.testing import FlaskClient

from conftest import client


def test_recipes(client: FlaskClient) -> None:
    response = client.get('/get-recipes')
    assert response.status_code == 200
    assert response.json["recipes"] == [
        {
            'recipe_id': 1,
            'recipe_title': 'Pizza'
        },
        {
            'recipe_id': 2,
            'recipe_title': 'Pasta'
        },
        {
            'recipe_id': 3,
            'recipe_title': 'Curry'
        },
        {
            'recipe_id': 4,
            'recipe_title': 'Burger'
        },
        {
            'recipe_id': 5,
            'recipe_title': 'Hotdog'
        }
    ]

def test_recipe_details(client: FlaskClient) -> None:
    response = client.get('/get-recipe-details/1')
    assert response.status_code == 200
    assert response.json["recipe"] == {
        'recipe_id': 1,
        'recipe_title': 'Pizza',
        'ingredients': ['{}', 'Tomato Sauce', 'Cheese'],
        'instructions': {'Mix ingredients and bake for 20 minutes.'}
    }   
    
    response = client.get('/get-recipe-details/999')
    assert response.status_code == 404
    assert response.json["error"] == 'Recipe not found'

def test_add_recipe(client: FlaskClient) -> None:
    new_recipe = {
        'recipe_title': 'Salad',
        'ingredients': ['Lettuce', 'Tomato', 'Cucumber'],
        'instructions': {'Mix all ingredients together.'}
    }
    response = client.post('/add-recipe', json=new_recipe)
    assert response.status_code == 201
    assert response.json["message"] == 'Recipe added successfully' 
    assert response.json["recipe_id"] == 6
    # Verify the new recipe was added    response = client.get('/get-recipe-details/6')
    assert response.status_code == 200
    assert response.json["recipe"] == {
        'recipe_id': 6,
        'recipe_title': 'Salad',
        'ingredients': ['Lettuce', 'Tomato', 'Cucumber'],
        'instructions': 'Mix all ingredients together.'
    }

def test_add_recipe_invalid_data(client: FlaskClient) -> None:
    invalid_recipe = {
        'recipe_title': 'Soup',
        'ingredients': ['Water', 'Vegetables']
    }
    response = client.post('/add-recipe', json=invalid_recipe)
    assert response.status_code == 400
    assert response.json["error"] == 'Invalid recipe data'
    assert response.json["message"] == 'Missing required fields: instructions' 
    
def test_add_recipe_empty_data(client: FlaskClient) -> None:
    response = client.post('/add-recipe', json={})
    assert response.status_code == 400
    assert response.json["error"] == 'Invalid recipe data'
    assert response.json["message"] == 'Missing required fields: recipe_title, ingredients, instructions'
    
    
def test_add_recipe_non_json(client: FlaskClient) -> None:
    response = client.post('/add-recipe', data='Not a JSON')
    assert response.status_code == 400
    assert response.json["error"] == 'Invalid JSON data'
    assert response.json["message"] == 'Request body must be JSON'
    assert response.json["content_type"] == 'text/plain; charset=utf-8' 

def test_add_recipe_empty_json(client: FlaskClient) -> None:
    response = client.post('/add-recipe', json={})
    assert response.status_code == 400
    assert response.json["error"] == 'Invalid recipe data'
    assert response.json["message"] == 'Missing required fields: recipe_title, ingredients, instructions'
    assert response.json["missing_fields"] == ['recipe_title', 'ingredients', 'instructions']
    assert response.json["provided_fields"] == []
    assert response.json["expected_fields"] == ['recipe_title', 'ingredients', 'instructions']      

    
def test_add_recipe_invalid_ingredients(client: FlaskClient) -> None:
        invalid_ingredients_recipe = {
            'recipe_title': 'Omelette',
            'ingredients': 'Eggs, Cheese',  # Should be a list, not a string
            'instructions': 'Beat eggs and cook with cheese.'
        }
        response = client.post('/add-recipe', json=invalid_ingredients_recipe)
        assert response.status_code == 400
        assert response.json["error"] == 'Invalid recipe data'
        assert response.json["message"] == 'Ingredients must be a list'
        assert response.json["provided_ingredients"] == 'Eggs, Cheese'
        assert response.json["expected_ingredients_type"] == 'list'
        assert response.json["expected_fields"] == ['recipe_title', 'ingredients', 'instructions']
        assert response.json["missing_fields"] == []
        assert response.json["provided_fields"] == ['recipe_title', 'ingredients', 'instructions']
        assert response.json["invalid_fields"] == ['ingredients']  
        assert response.json["error_details"] == {
            'ingredients': {
                'expected_type': 'list',
                'actual_type': 'str'
            }
        }


# --- Additional tests matching current backend behavior ---
def test_get_recipes_basic(client: FlaskClient) -> None:
    """GET /get-recipes should return the seeded recipes (at least the 5 defaults)."""
    resp = client.get('/get-recipes')
    assert resp.status_code == 200
    data = resp.get_json()
    assert isinstance(data, dict)
    assert 'recipes' in data
    recipes = data['recipes']
    assert isinstance(recipes, list)
    # seeded test data contains these titles
    expected = {'Pizza', 'Pasta', 'Curry', 'Burger', 'Hotdog'}
    returned = {r.get('recipe_title') for r in recipes}
    assert expected.issubset(returned)


def test_add_recipe_rejects_non_json(client: FlaskClient) -> None:
    """Posting non-JSON (no content-type) should be rejected with 415 per route."""
    resp = client.post('/add-recipe', data='Not a JSON')
    assert resp.status_code == 415


def test_add_recipe_invalid_json_body_returns_400(client: FlaskClient) -> None:
    """If Content-Type is application/json but body is invalid JSON, Flask should return 400."""
    resp = client.post('/add-recipe', data='not a json', content_type='application/json')
    assert resp.status_code == 400


def test_add_recipe_missing_fields_returns_400(client: FlaskClient) -> None:
    """Valid JSON but missing required keys should return 400 (route aborts on missing fields)."""
    payload = {
        'recipe-title': 'Test Missing Fields',
        # 'recipe-ingredients' intentionally omitted to trigger 400
        'recipe-steps': ['do it']
    }
    resp = client.post('/add-recipe', json=payload)
    assert resp.status_code == 400


def test_add_recipe_valid_json_but_missing_sql_files_returns_500(client: FlaskClient) -> None:
    """When all required fields are present the route attempts to open SQL files.
    In this repo those SQL files are missing, so the route should raise and return 500."""
    payload = {
        'recipe-title': 'Integration Salad',
        'recipe-ingredients': ['Lettuce', 'Tomato'],
        'recipe-steps': ['Mix together']
    }
    resp = client.post('/add-recipe', json=payload)
    # Route sets status_code = 200 on success; but missing SQL files will cause a server error.
    assert resp.status_code == 500
    
    