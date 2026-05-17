from flask.testing import FlaskClient

from tests.conftest import client


def test_account_creation_valid(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": "test@test",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 201


def test_account_creation_missing_fname(client: FlaskClient) -> None:
    body = {
        "user_lname": "user",
        "user_email": "test@test",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_creation_missing_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_email": "test@test",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_creation_missing_password(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": "test@test",
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_creation_missing_email(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_blank_fname(client: FlaskClient) -> None:
    body = {
        "user_fname": "",
        "user_lname": "user",
        "user_email": "test@test",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_blank_lname(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "",
        "user_email": "test@test",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_blank_password(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": "test@test",
        "user_password": ""
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_blank_email(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": "",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_account_creation_missing_form(client: FlaskClient) -> None:
    response = client.post('/create-account', data={})
    assert response.status_code == 400


def test_duplicate_email(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": "test@test",
        "user_password": "123456"
    }

    first = client.post('/create-account', data=body)
    assert first.status_code == 201

    second = client.post('/create-account', data=body)
    assert second.status_code == 409


def test_invalid_email_format(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": "not-an-email",
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_short_password(client: FlaskClient) -> None:
    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": "test@test",
        "user_password": "123"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400


def test_max_length_email(client: FlaskClient) -> None:
    long_email = "a" * 312 + "@test.com"  # 321 characters total

    body = {
        "user_fname": "new",
        "user_lname": "user",
        "user_email": long_email,
        "user_password": "123456"
    }

    response = client.post('/create-account', data=body)
    assert response.status_code == 400
