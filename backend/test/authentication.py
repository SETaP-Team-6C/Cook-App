from flask.testing import FlaskClient

from conftest import client


def test_successful(client: FlaskClient) -> None:
    # Test successful authentication
    body = {
        "user_fname": "test",
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 200
    assert response.json["user"]["user_id"] == 1


def test_bad_username(client: FlaskClient) -> None:
    # Test bad username
    body = {
        "user_fname": "fake",
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is None


def test_bad_fname(client: FlaskClient) -> None:
    # Test missing first name
    body = {
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    assert response.json is None


def test_bad_lname(client: FlaskClient) -> None:
    # Test missing last name
    body = {
        "user_fname": "test"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    assert response.json is None
