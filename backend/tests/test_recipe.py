from flask.testing import FlaskClient

from tests.conftest import client


def test_recipes(client: FlaskClient) -> None:
    response = client.get('/get-recipes')
    assert response.status_code == 200
    assert response.json is not None
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


def test_add_recipe(client: FlaskClient) -> None:
    # Prepare a minimal valid recipe payload
    payload = {
        "recipe-title": "Unittest Recipe",
        "recipe-ingredients": [
            {
                "ingredient-name": "Salt",
                "ingredient-amount": 1,
                "ingredient-calories": 0,
                "ingredient-unit": "g",
            }
        ],
        "recipe-steps": [
            {
                "step-index": "1",
                "step-description": "Mix ingredients",
                "step-duration": "PT0M",
            }
        ],
        "recipe-time": "PT5M",
        "recipe-difficulty": "easy",
        # dietary/allergies optional
        "recipe-dietary": ["Vegan"],
    }

    response = client.post('/add-recipe', json=payload)
    assert response.status_code == 200

    # Verify the new recipe appears in the list
    get_resp = client.get('/get-recipes')
    assert get_resp.status_code == 200
    titles = [r['recipe_title'] for r in get_resp.json['recipes']]
    assert 'Unittest Recipe' in titles


def test_add_recipe_missing_fields(client: FlaskClient) -> None:
    # Missing recipe-ingredients should return 400
    payload = {
        "recipe-title": "Bad Recipe",
        "recipe-steps": [
            {"step-index": "1", "step-description": "Do", "step-duration": "PT1M"}
        ],
        "recipe-time": "PT1M",
        "recipe-difficulty": "easy",
    }

    response = client.post('/add-recipe', json=payload)
    assert response.status_code == 400


def test_add_recipe_multiple_ingredients_and_steps(client: FlaskClient) -> None:
    payload = {
        "recipe-title": "Full Recipe",
        "recipe-ingredients": [
            {
                "ingredient-name": "Flour",
                "ingredient-amount": 200,
                "ingredient-calories": 800,
                "ingredient-unit": "g",
            },
            {
                "ingredient-name": "Water",
                "ingredient-amount": 100,
                "ingredient-calories": 0,
                "ingredient-unit": "ml",
            }
        ],
        "recipe-steps": [
            {"step-index": "1", "step-description": "Mix", "step-duration": "PT5M"},
            {"step-index": "2", "step-description": "Bake", "step-duration": "PT20M"},
        ],
        "recipe-time": "PT25M",
        "recipe-difficulty": "medium",
        "recipe-dietary": ["Vegetarian"],
        "recipe-allergies": ["Others"],
    }

    response = client.post('/add-recipe', json=payload)
    assert response.status_code == 200


def test_add_recipe_others_text_fields(client: FlaskClient) -> None:
    payload = {
        "recipe-title": "Other Fields",
        "recipe-ingredients": [
            {
                "ingredient-name": "Custom",
                "ingredient-amount": 1,
                "ingredient-calories": 1,
                "ingredient-unit": "pcs",
            }
        ],
        "recipe-steps": [
            {"step-index": "1", "step-description": "Do", "step-duration": "PT1M"}
        ],
        "recipe-time": "PT1M",
        "recipe-difficulty": "easy",
        "recipe-dietary": ["Other option text"],
        "recipe-allergies": ["Other allergy text"],
    }

    response = client.post('/add-recipe', json=payload)
    assert response.status_code == 200


def test_add_recipe_missing_step_field(client: FlaskClient) -> None:
    # Missing step-duration should return 400
    payload = {
        "recipe-title": "Bad Step",
        "recipe-ingredients": [
            {"ingredient-name": "A", "ingredient-amount": 1, "ingredient-calories": 1, "ingredient-unit": "g"}
        ],
        "recipe-steps": [
            {"step-index": "1", "step-description": "No duration"}
        ],
        "recipe-time": "PT1M",
        "recipe-difficulty": "easy",
    }

    response = client.post('/add-recipe', json=payload)
    assert response.status_code == 400


import pytest
from itertools import product


@pytest.mark.parametrize("ingredients_valid", [True, False])
@pytest.mark.parametrize("steps_valid", [True, False])
@pytest.mark.parametrize("dietary_kind", ["none", "normal", "other"])
@pytest.mark.parametrize("allergy_kind", ["none", "normal", "other"])
def test_add_recipe_combinations(client: FlaskClient, ingredients_valid, steps_valid, dietary_kind, allergy_kind) -> None:
    """
    Test the /add-recipe endpoint against combinations of:
      - ingredients_valid: ingredient amount is int vs string
      - steps_valid: step contains duration vs missing
      - dietary_kind: none / normal (Vegan) / other (custom text)
      - allergy_kind: none / normal (Peanuts) / other (custom text)

    Expected: request succeeds (200) only when ingredients_valid and steps_valid are both True.
    """

    # Ingredients
    if ingredients_valid:
        ingredients = [
            {
                "ingredient-name": "TestIng",
                "ingredient-amount": 10,
                "ingredient-calories": 5,
                "ingredient-unit": "g",
            }
        ]
    else:
        ingredients = [
            {
                "ingredient-name": "BadIng",
                "ingredient-amount": "ten",  # invalid
                "ingredient-calories": 5,
                "ingredient-unit": "g",
            }
        ]

    # Steps
    if steps_valid:
        steps = [
            {"step-index": "1", "step-description": "Do", "step-duration": "PT1M"}
        ]
    else:
        steps = [
            {"step-index": "1", "step-description": "Do"}  # missing duration
        ]

    payload = {
        "recipe-title": "Combo Recipe",
        "recipe-ingredients": ingredients,
        "recipe-steps": steps,
        "recipe-time": "PT1M",
        "recipe-difficulty": "easy",
    }

    # dietary
    if dietary_kind == "normal":
        payload["recipe-dietary"] = ["Vegan"]
    elif dietary_kind == "other":
        payload["recipe-dietary"] = ["CustomDiet"]

    # allergies
    if allergy_kind == "normal":
        payload["recipe-allergies"] = ["Peanuts"]
    elif allergy_kind == "other":
        payload["recipe-allergies"] = ["CustomAllergy"]

    response = client.post('/add-recipe', json=payload)

    expected_status = 200 if (ingredients_valid and steps_valid) else 400
    assert response.status_code == expected_status


def test_add_recipe_invalid_ingredient_types(client: FlaskClient) -> None:
    # ingredient-amount must be int; sending string should result in 400
    payload = {
        "recipe-title": "Bad Types",
        "recipe-ingredients": [
            {
                "ingredient-name": "Sugar",
                "ingredient-amount": "one",
                "ingredient-calories": 10,
                "ingredient-unit": "g",
            }
        ],
        "recipe-steps": [
            {"step-index": "1", "step-description": "Do", "step-duration": "PT1M"}
        ],
        "recipe-time": "PT1M",
        "recipe-difficulty": "easy",
    }

    response = client.post('/add-recipe', json=payload)
    assert response.status_code == 400
