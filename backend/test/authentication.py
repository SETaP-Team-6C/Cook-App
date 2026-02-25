from flask.testing import FlaskClient

from conftest import client

def test_authentication(client: FlaskClient) -> None:
    body = {
        "user_fname": "test",
        "user_lname": "user",
    }

    response = client.post("/authenticate", data=body)

    assert response.status_code == 200
    assert response.json["user"]["user_id"] == 1



