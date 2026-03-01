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
