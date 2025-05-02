import os
from app import create_app

if __name__ == "__main__":
    app = create_app()
    env = os.getenv("ENV", "dev")
    port = int(os.getenv("PORT", "8082"))
    app.run(host="0.0.0.0", port=port, debug=env == "dev")