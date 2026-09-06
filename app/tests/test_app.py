import requests

BASE_URL = "http://test-app:8080"


def test_home():
    response = requests.get(f"{BASE_URL}/")

    assert response.status_code == 200

    data = response.json()

    assert data["app"] == "test-app"
    assert data["status"] == "running"


def test_health():
    response = requests.get(f"{BASE_URL}/health")

    assert response.status_code == 200

    data = response.json()

    assert data["status"] == "healthy"


def test_hello():
    response = requests.get(f"{BASE_URL}/hello")

    assert response.status_code == 200

    data = response.json()

    assert data["message"] == "Hello from Kubernetes"


def test_create_user():
    user = {
        "name": "John",
        "email": "john@example.com"
    }

    response = requests.post(
        f"{BASE_URL}/users",
        json=user
    )

    assert response.status_code == 201

    data = response.json()

    assert data["name"] == "John"
    assert data["email"] == "john@example.com"
