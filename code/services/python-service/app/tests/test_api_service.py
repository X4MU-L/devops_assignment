import pytest
import requests
from app.services import ApiService
from app.config import Config
from unittest.mock import patch

@pytest.fixture
def config():
    """Fixture for a valid Config instance."""
    return Config()

@pytest.fixture
def api_service(config):
    """Fixture for an ApiService instance."""
    return ApiService(config)

def test_health_check(api_service):
    """Test ApiService.health_check returns correct status and env."""
    result = api_service.health_check()
    assert result == {"status": "healthy", "env": api_service.config.env}
    assert result["env"] == "dev"  # Default env from Config

@patch("requests.get")
def test_chain_request_success(mock_get, api_service):
    """Test ApiService.chain_request with a successful Go service response."""
    mock_get.return_value.status_code = 200
    mock_get.return_value.text = "Go Service (dev) is healthy"
    result = api_service.chain_request()
    assert result == {
        "python_service": "healthy",
        "go_service": "Go Service (dev) is healthy"
    }
    mock_get.assert_called_once_with(f"{api_service.config.go_service_url}/health", timeout=5)

@patch("requests.get")
def test_chain_request_timeout(mock_get, api_service):
    """Test ApiService.chain_request with a timeout error."""
    mock_get.side_effect = requests.exceptions.Timeout("Request timed out")
    result = api_service.chain_request()
    assert "error" in result
    assert result["error"] == "Failed to reach Go service: Request timed out"
    mock_get.assert_called_once_with(f"{api_service.config.go_service_url}/health", timeout=5)

@patch("requests.get")
def test_chain_request_non_200(mock_get, api_service):
    """Test ApiService.chain_request with a non-200 response."""
    mock_get.return_value.status_code = 500
    mock_get.return_value.text = "Internal Server Error"
    mock_get.return_value.raise_for_status.side_effect = requests.exceptions.HTTPError("500 Server Error")
    result = api_service.chain_request()
    assert "error" in result
    assert result["error"].startswith("Failed to reach Go service: 500 Server Error")
    mock_get.assert_called_once_with(f"{api_service.config.go_service_url}/health", timeout=5)

@patch("requests.get")
def test_chain_request_malformed_response(mock_get, api_service):
    """Test ApiService.chain_request with a malformed Go service response."""
    mock_get.return_value.status_code = 200
    mock_get.return_value.text = ""  # Empty response
    result = api_service.chain_request()
    assert result == {
        "python_service": "healthy",
        "go_service": ""
    }
    mock_get.assert_called_once_with(f"{api_service.config.go_service_url}/health", timeout=5)