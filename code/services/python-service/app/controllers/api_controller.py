from typing import Dict, Any, Tuple
from app.services import ApiService
import logging

logger = logging.getLogger(__name__)

class ApiController:
    """Handles HTTP request processing and response formatting."""
    def __init__(self, service: ApiService):
        self.service = service
        logger.info("Initialized ApiController")

    def health(self) -> Tuple[Dict[str, str], int]:
        """Handle health endpoint request."""
        logger.debug("Handling health endpoint")
        return self.service.health_check(), 200

    def chain(self) -> Tuple[Dict[str, Any], int]:
        """Handle chain endpoint request."""
        logger.debug("Handling chain endpoint")
        return self.service.chain_request(), 200