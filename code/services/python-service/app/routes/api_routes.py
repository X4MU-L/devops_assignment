from flask import Blueprint, jsonify
from app.controllers import ApiController
from typing import Any, Dict, Tuple

def register_routes(app, controller: ApiController) -> None:
    """Register API routes with the Flask app."""
    api_bp = Blueprint("api", __name__)

    @api_bp.route("/health", methods=["GET"])
    def health() -> Tuple[Dict[str, Any], int]:
        result, status = controller.health()
        return jsonify(result), status

    @api_bp.route("/chain", methods=["GET"])
    def chain() -> Tuple[Dict[str, Any], int]:
        result, status = controller.chain()
        return jsonify(result), status

    app.register_blueprint(api_bp)