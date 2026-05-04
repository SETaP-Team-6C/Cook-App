from flask import Flask
from flask.testing import FlaskClient
from pytest import fixture
from main.app import create_app
from main.database import Database


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

@fixture(autouse=True)
def clean_up():
    yield

    Database.delete_test_database()

