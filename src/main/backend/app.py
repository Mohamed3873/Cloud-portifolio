import os
from dotenv import load_dotenv
from flask import Flask, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
CORS(app)
load_dotenv()

# Connect to the MySQL database
def get_db_connection():
    try:
        # Log to see the database connection details
        print(f"Attempting to connect to database with user: {os.getenv('DB_USER')}")

        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', '127.0.0.1'),  # Ensure it connects via Cloud SQL Proxy
            port=os.getenv('DB_PORT', '3306'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME')

        )

        if connection.is_connected():
            print("Successfully connected to the database")
        else:
            print("Failed to connect to the database")

        return connection
    except Error as e:
        # Print the error message for more details
        print(f"Error while connecting to database: {e}")
        return None

print(f"DB_USER: {os.getenv('DB_USER')}")
print(f"DB_PASSWORD: {os.getenv('DB_PASSWORD')}")

@app.route('/')
def hello_world():
    return 'Hello, World!'

@app.route('/data')
def fetch_data():
    print("Fetching data from the database...")

    connection = get_db_connection()

    if connection is None:
        print("Database connection failed")
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute('SELECT * FROM terraform_database.items')  # replace with your table name
        data = cursor.fetchall()
        cursor.close()
        connection.close()
        print("Data fetched successfully")
        return jsonify(data)
    except Error as e:
        print(f"Error during data retrieval: {e}")
        return jsonify({'error': f'Database query failed: {e}'}), 500

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
