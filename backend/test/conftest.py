from flask import Flask
from flask.testing import FlaskClient
from pytest import fixture
from backend.app import create_app

@fixture
def app() -> Flask:
    app = create_app()
    app.config.update({
        "TESTING": True,
    })

    yield app

@fixture
def client(app: Flask) -> FlaskClient:
    return app.test_client()

