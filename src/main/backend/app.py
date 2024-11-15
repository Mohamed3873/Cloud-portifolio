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
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST'),
            port=int(os.getenv('DB_PORT', 3306)),  # Default to 3306 if DB_PORT is not set
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME')
        )
        if connection.is_connected():
            print("Successfully connected to the database")
        return connection
    except Error as e:
        print(f"Error: {e}")
        return None


@app.route('/')
def hello_world():
    return 'Hello, World!'


@app.route('/data')
def fetch_data():
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    cursor.execute('SELECT * FROM terraform_database.items')  # replace with your table name
    data = cursor.fetchall()
    cursor.close()
    connection.close()
    return jsonify(data)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
