import os
from typing import Dict, Any
import logging

logger = logging.getLogger(__name__)

class Config:
    """Handles environment-specific configuration with validation."""
    def __init__(self):
        self.env = os.getenv("ENV", "dev")
        self.port = int(os.getenv("PORT", "8082"))
        self.go_service_url = os.getenv("GO_SERVICE_URL", "http://go-service:8081")
        self._validate()

    def _validate(self) -> None:
        """Validate required configuration."""
        if not self.port:
            logger.error("PORT is required")
            raise ValueError("PORT is required")
        if not self.go_service_url:
            logger.error("GO_SERVICE_URL is required")
            raise ValueError("GO_SERVICE_URL is required")
        logger.info(f"Loaded config: env={self.env}, port={self.port}, go_service_url={self.go_service_url}")

    def to_dict(self) -> Dict[str, Any]:
        """Return configuration as a dictionary."""
        return {
            "env": self.env,
            "port": self.port,
            "go_service_url": self.go_service_url
        }