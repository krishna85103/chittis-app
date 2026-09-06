from flask import Flask, jsonify, request

app = Flask(__name__)

users = []

@app.get("/")
def home():
    return jsonify({
        "app": "test-app",
        "status": "running"
    })

@app.get("/health")
def health():
    return jsonify({
        "status": "healthy"
    })

@app.get("/hello")
def hello():
    return jsonify({
        "message": "Hello from Kubernetes"
    })

@app.get("/users")
def get_users():
    return jsonify(users)

@app.post("/users")
def create_user():
    user = request.json
    users.append(user)
    return jsonify(user), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
