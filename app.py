from flask import Flask, request, jsonify
import mysql.connector
import os

app = Flask(__name__)

def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "db"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "root"),
        database=os.getenv("DB_NAME", "yugioh")
    )


# CREATE
@app.route('/cartas', methods=['POST'])
def criar_carta():
    data = request.json

    if not data or not all(k in data for k in ("nome", "tipo", "ataque", "defesa")):
        return jsonify({"error": "Dados incompletos"}), 400

    conn = get_connection()
    cursor = conn.cursor()

    sql = "INSERT INTO cartas (nome, tipo, ataque, defesa) VALUES (%s, %s, %s, %s)"
    cursor.execute(sql, (
        data['nome'],
        data['tipo'],
        data['ataque'],
        data['defesa']
    ))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({"message": "Carta criada"}), 201


# READ ALL (com filtro opcional)
@app.route('/cartas', methods=['GET'])
def listar_cartas():
    tipo = request.args.get('tipo')

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    if tipo:
        cursor.execute("SELECT * FROM cartas WHERE tipo = %s", (tipo,))
    else:
        cursor.execute("SELECT * FROM cartas")

    cartas = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(cartas)


# READ ONE
@app.route('/cartas/<int:id>', methods=['GET'])
def buscar_carta(id):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM cartas WHERE id = %s", (id,))
    carta = cursor.fetchone()

    cursor.close()
    conn.close()

    if not carta:
        return jsonify({"error": "Carta não encontrada"}), 404

    return jsonify(carta)


# UPDATE
@app.route('/cartas/<int:id>', methods=['PUT'])
def atualizar_carta(id):
    data = request.json

    if not data:
        return jsonify({"error": "Dados não enviados"}), 400

    conn = get_connection()
    cursor = conn.cursor()

    sql = """
    UPDATE cartas
    SET nome=%s, tipo=%s, ataque=%s, defesa=%s
    WHERE id=%s
    """
    cursor.execute(sql, (
        data.get('nome'),
        data.get('tipo'),
        data.get('ataque'),
        data.get('defesa'),
        id
    ))

    conn.commit()

    if cursor.rowcount == 0:
        cursor.close()
        conn.close()
        return jsonify({"error": "Carta não encontrada"}), 404

    cursor.close()
    conn.close()

    return jsonify({"message": "Carta atualizada"})


# DELETE
@app.route('/cartas/<int:id>', methods=['DELETE'])
def deletar_carta(id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM cartas WHERE id = %s", (id,))
    conn.commit()

    if cursor.rowcount == 0:
        cursor.close()
        conn.close()
        return jsonify({"error": "Carta não encontrada"}), 404

    cursor.close()
    conn.close()

    return jsonify({"message": "Carta deletada"})


# HEALTHCHECK (bom pra Docker)
@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)