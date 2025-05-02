import pytest
import os
from app.config import Config

def test_config_valid():
    """Test Config initializes with valid environment variables."""
    os.environ["PORT"] = "8082"
    os.environ["GO_SERVICE_URL"] = "http://go-service:8081"
    config = Config()
    assert config.env == "dev"
    assert config.port == 8082
    assert config.go_service_url == "http://go-service:8081"

def test_config_missing_port():
    """Test Config raises ValueError for missing PORT."""
    os.environ.pop("PORT", None)
    with pytest.raises(ValueError, match="PORT is required"):
        Config()

def test_config_missing_go_service_url():
    """Test Config raises ValueError for missing GO_SERVICE_URL."""
    os.environ["PORT"] = "8082"
    os.environ.pop("GO_SERVICE_URL", None)
    with pytest.raises(ValueError, match="GO_SERVICE_URL is required"):
        Config()

def test_config_invalid_port():
    """Test Config raises ValueError for invalid PORT."""
    os.environ["PORT"] = "invalid"
    os.environ["GO_SERVICE_URL"] = "http://go-service:8081"
    with pytest.raises(ValueError, match="invalid literal for int()"):
        Config()