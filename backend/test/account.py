from flask.testing import FlaskClient

from conftest import client


def test_account_creation_valid(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 201


def test_account_creation_missing_fname(client: FlaskClient) -> None:
    body = {
        "user_lname": "user"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_creation_missing_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "new"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400
