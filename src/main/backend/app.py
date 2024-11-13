import os
from dotenv import load_dotenv
from flask import Flask, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)
load_dotenv()


# Connect to the MySQL database
# Connect to the MySQL database using environment variables
def get_db_connection():
    connection = mysql.connector.connect(
        host=os.getenv('DB_HOST'),        # Cloud SQL public IP
        user=os.getenv('DB_USER'),        # Database username
        password=os.getenv('DB_PASSWORD'), # Database password
        database=os.getenv('DB_NAME')     # Database name
    )
    return connection


@app.route('/')
def hello_world():
    return 'Hello, World!'


@app.route('/data')
def fetch_data():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute('SELECT * FROM terraform_database.items')  # replace with your table name
    data = cursor.fetchall()
    cursor.close()
    connection.close()
    return jsonify(data)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)

