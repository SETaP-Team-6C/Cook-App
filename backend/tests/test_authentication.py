from flask.testing import FlaskClient

from tests.conftest import client


def test_successful(client: FlaskClient) -> None:
    # Test successful authentication
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "123456",

    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 200
    assert response.json is not None
    assert response.json["success"] is True
    assert response.json["user"]["user_id"] == 1
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) == 1


def test_incorrect_fname(client: FlaskClient) -> None:
    body = {
        "user_fname": "fake",
        "user_lname": "user",
        "user_password": "123456"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is not None
    assert response.json["success"] is False
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_incorrect_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "person",
        "user_password": "123456"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is not None
    assert response.json["success"] is False
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_incorrect_password(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": "password"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is not None
    assert response.json["success"] is False
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_missing_fname(client: FlaskClient) -> None:
    body = {
        "user_lname": "user",
        "user_password": "123456"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_missing_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_password": "123456"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_missing_password(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_blank_fname(client: FlaskClient) -> None:
    body = {
        "user_fname": "",
        "user_lname": "user",
        "user_password": "123456"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is not None
    assert response.json["success"] is False
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_blank_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "",
        "user_password": "123456"
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is not None
    assert response.json["success"] is False
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_blank_password(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "user",
        "user_password": ""
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is not None
    assert response.json["success"] is False
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_empty_inputs(client: FlaskClient) -> None:
    body = {
        "user_fname": "",
        "user_lname": "",
        "user_password": ""
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 401
    assert response.json is not None
    assert response.json["success"] is False
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None


def test_empty_body(client: FlaskClient) -> None:
    body = {
    }

    response = client.post("/authenticate", data=body)
    assert response.status_code == 400
    with client.session_transaction() as sess:
        assert sess.get("user_id", None) is None
