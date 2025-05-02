import pytest
from flask import Flask
from flask.testing import FlaskClient
from app.controllers import ApiController
from app.routes import register_routes
from unittest.mock import Mock

@pytest.fixture
def app():
    """Fixture for a Flask app with registered routes."""
    app = Flask(__name__)
    controller = Mock(spec=ApiController)
    register_routes(app, controller)
    return app

@pytest.fixture
def client(app):
    """Fixture for a Flask test client."""
    return app.test_client()

@pytest.fixture
def controller():
    """Fixture for a mocked ApiController."""
    return Mock(spec=ApiController)

def test_health_route(client, controller, app):
    """Test /health endpoint returns correct response."""
    controller.health.return_value = ({"status": "healthy", "env": "dev"}, 200)
    with app.app_context():
        response = client.get("/health")
    assert response.status_code == 200
    assert response.json == {"status": "healthy", "env": "dev"}
    controller.health.assert_called_once()

def test_chain_route(client, controller, app):
    """Test /chain endpoint returns correct response."""
    controller.chain.return_value = (
        {"python_service": "healthy", "go_service": "Go Service (dev) is healthy"},
        200
    )
    with app.app_context():
        response = client.get("/chain")
    assert response.status_code == 200
    assert response.json == {
        "python_service": "healthy",
        "go_service": "Go Service (dev) is healthy"
    }
    controller.chain.assert_called_once()

def test_chain_route_error(client, controller, app):
    """Test /chain endpoint handles error response."""
    controller.chain.return_value = ({"error": "Failed to reach Go service"}, 200)
    with app.app_context():
        response = client.get("/chain")
    assert response.status_code == 200
    assert response.json == {"error": "Failed to reach Go service"}
    controller.chain.assert_called_once()

def test_health_route_invalid_method(client, controller, app):
    """Test /health endpoint with invalid HTTP method."""
    with app.app_context():
        response = client.post("/health")
    assert response.status_code == 405  # Method Not Allowed
    controller.health.assert_not_called()

def test_chain_route_invalid_method(client, controller, app):
    """Test /chain endpoint with invalid HTTP method."""
    with app.app_context():
        response = client.post("/chain")
    assert response.status_code == 405  # Method Not Allowed
    controller.chain.assert_not_called()