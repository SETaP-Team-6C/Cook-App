from flask.testing import FlaskClient

from tests.conftest import client


def test_successful(client: FlaskClient) -> None:
    # Test successful authentication
    body = {
        "user_fname": "test",
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 200
    assert response.json["user"]["user_id"] == 1


def test_incorrect_fname(client: FlaskClient) -> None:
    body = {
        "user_fname": "fake",
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is None


def test_incorrect_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "person",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is None


def test_missing_fname(client: FlaskClient) -> None:
    body = {
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    assert response.json is None


def test_missing_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "test"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    assert response.json is None


def test_blank_fname(client: FlaskClient) -> None:
    body = {
        "user_fname": "",
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is None


def test_blank_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": ""
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is None


def test_empty_inputs(client: FlaskClient) -> None:
    body = {
        "user_fname": "",
        "user_lname": ""
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is None


def test_empty_body(client: FlaskClient) -> None:
    body = {
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    assert response.json is None
