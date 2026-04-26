"""
flask-app: A minimal Python microservice for the EKS platform demo.
Exposes three endpoints:
  GET /         - welcome message
  GET /health   - Kubernetes liveness/readiness probe target
  GET /info     - returns hostname and environment metadata
"""

import os
import socket
from flask import Flask, jsonify

app = Flask(__name__)

APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "staging")


@app.route("/")
def index():
    return jsonify({
        "service": "flask-app",
        "version": APP_VERSION,
        "message": "EKS Platform demo – Ravinder Kumar",
    })


@app.route("/health")
def health():
    """Kubernetes liveness and readiness probe endpoint."""
    return jsonify({"status": "healthy"}), 200


@app.route("/info")
def info():
    """Returns pod hostname and environment – useful for verifying Kubernetes load balancing."""
    return jsonify({
        "hostname": socket.gethostname(),
        "environment": ENVIRONMENT,
        "version": APP_VERSION,
    })


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
