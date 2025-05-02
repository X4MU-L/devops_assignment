import requests
from typing import Dict, Any
from app.config import Config
import logging

logger = logging.getLogger(__name__)

class ApiService:
    """Handles business logic and external service communication."""
    def __init__(self, config: Config):
        self.config = config
        logger.info("Initialized ApiService")

    def health_check(self) -> Dict[str, str]:
        """Return health status of the service."""
        logger.debug("Processing health check")
        return {"status": "healthy", "env": self.config.env}

    def chain_request(self) -> Dict[str, Any]:
        """Proxy request to Go service and return combined status."""
        logger.debug(f"Sending chain request to {self.config.go_service_url}/health")
        try:
            response = requests.get(f"{self.config.go_service_url}/health", timeout=5)
            response.raise_for_status()
            logger.info("Successfully received response from Go service")
            return {"python_service": "healthy", "go_service": response.text}
        except requests.RequestException as e:
            logger.error(f"Failed to reach Go service: {str(e)}")
            return {"error": f"Failed to reach Go service: {str(e)}"}