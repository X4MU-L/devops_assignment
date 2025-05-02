import pytest
from app.controllers import ApiController
from app.services import ApiService
from app.config import Config
from unittest.mock import Mock

@pytest.fixture
def config():
    """Fixture for a valid Config instance."""
    return Config()

@pytest.fixture
def api_service(config):
    """Fixture for a mocked ApiService instance."""
    return Mock(spec=ApiService, config=config)

@pytest.fixture
def api_controller(api_service):
    """Fixture for an ApiController instance."""
    return ApiController(api_service)

def test_health(api_controller, api_service):
    """Test ApiController.health calls service and returns correct response."""
    api_service.health_check.return_value = {"status": "healthy", "env": "dev"}
    result, status = api_controller.health()
    assert result == {"status": "healthy", "env": "dev"}
    assert status == 200
    api_service.health_check.assert_called_once()

def test_chain(api_controller, api_service):
    """Test ApiController.chain calls service and returns correct response."""
    api_service.chain_request.return_value = {
        "python_service": "healthy",
        "go_service": "Go Service (dev) is healthy"
    }
    result, status = api_controller.chain()
    assert result == {
        "python_service": "healthy",
        "go_service": "Go Service (dev) is healthy"
    }
    assert status == 200
    api_service.chain_request.assert_called_once()

def test_chain_error(api_controller, api_service):
    """Test ApiController.chain handles service error."""
    api_service.chain_request.return_value = {
        "error": "Failed to reach Go service"
    }
    result, status = api_controller.chain()
    assert result == {"error": "Failed to reach Go service"}
    assert status == 200
    api_service.chain_request.assert_called_once()

def test_health_unexpected_service_output(api_controller, api_service):
    """Test ApiController.health with unexpected service output."""
    api_service.health_check.return_value = {}  # Empty response
    result, status = api_controller.health()
    assert result == {}
    assert status == 200
    api_service.health_check.assert_called_once()