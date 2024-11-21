import os
import requests

# Load environment variables from .env
from dotenv import load_dotenv
load_dotenv()

BACKEND_URL = os.getenv("BACKEND_URL", "http://34.77.4.205:8080")

def test_root_endpoint():
    response = requests.get(f"{BACKEND_URL}/")
    assert response.status_code == 200, "Root endpoint failed"
    assert response.text == "Hello, World!", "Unexpected response from root endpoint"

def test_data_endpoint():
    response = requests.get(f"{BACKEND_URL}/data")
    assert response.status_code == 200, "Data endpoint failed"
    assert isinstance(response.json(), list), "Expected a list of items from the database"

if __name__ == "__main__":
    test_root_endpoint()
    test_data_endpoint()
    print("All API tests passed!")
