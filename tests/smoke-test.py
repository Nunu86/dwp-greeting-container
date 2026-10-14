import json
import urllib.error
import urllib.request

BASE_URL = "http://localhost:8080"


def get_json(path):
    with urllib.request.urlopen(BASE_URL + path, timeout=5) as response:
        assert response.status == 200, f"{path}: unexpected HTTP status"
        return json.load(response)


health = get_json("/healthz")
assert health["status"] == "ok"
print("PASS: /healthz")

info = get_json("/info")
assert "greeting" in info
assert "port" in info
print("PASS: /info")

greeting = get_json("/")
assert "message" in greeting
print("PASS: /")

print("All HTTP smoke tests passed!")
