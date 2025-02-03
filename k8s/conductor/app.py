from flask import Flask, jsonify
import requests

app = Flask(__name__)

# Base URL for the Envoy gateway
ENVOY_URL = "http://envoy.pool-side.cc"

# Endpoints for each AI service
ENDPOINTS = {
    "openai": "/openai",
    "ollama": "/ollama",
    "anthropic": "/anthropic"
}

@app.route("/")
def index():
    results = {}
    for service, path in ENDPOINTS.items():
        url = ENVOY_URL + path
        try:
            resp = requests.get(url, timeout=5)
            results[service] = {
                "status": resp.status_code,
                "response": resp.text
            }
        except Exception as e:
            results[service] = {"error": str(e)}
    return jsonify(results)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

