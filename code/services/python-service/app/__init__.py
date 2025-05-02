from flask import Flask
from app.config import Config
from app.services import ApiService
from app.controllers import ApiController
from app.routes import register_routes
import logging

def create_app() -> Flask:
    """Initialize and configure the Flask application."""
    app = Flask(__name__)

    # Set up logging
    logging.basicConfig(
        level=logging.DEBUG if Config().env == "dev" else logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
    )
    logger = logging.getLogger(__name__)
    logger.info("Initializing Flask application")

    # Load config and initialize components
    config = Config()
    service = ApiService(config)
    controller = ApiController(service)

    # Register routes
    register_routes(app, controller)

    return app