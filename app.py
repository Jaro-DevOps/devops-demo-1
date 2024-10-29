from flask import Flask, jsonify, request
import psycopg2

app = Flask(__name__)

# Konfiguracja połączenia z bazą danych PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(
        host="db",  # Host bazy danych (używany w Dockerze lub Minikube)
        database="mydatabase",
        user="myuser",
        password="mypassword"
    )
    return conn

# Strona główna
@app.route('/')
def home():
    return "Hello, this is a simple Flask app for DevOps demo!"

# Endpoint do pobrania danych z bazy danych
@app.route('/data', methods=['GET'])
def get_data():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM mytable;')
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(rows)

# Endpoint do dodawania danych do bazy
@app.route('/data', methods=['POST'])
def add_data():
    new_data = request.json['data']
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('INSERT INTO mytable (data) VALUES (%s)', (new_data,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "Data added successfully!"}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

