from flask import Flask, request, jsonify
import sqlite3
from dna_analysis import is_mutant, init_db

app = Flask(__name__)

@app.route('/mutant/', methods=['POST'])
def mutant():
    try:
        data = request.get_json()
        if 'dna' not in data:
            return jsonify({'error': 'Missing DNA data'}), 400

        dna = data['dna']
        if not isinstance(dna, list) or not all(isinstance(row, str) for row in dna):
            return jsonify({'error': 'DNA must be a list of strings'}), 400

        is_mutant_flag = is_mutant(dna)

        # Store the DNA record in the database
        conn = sqlite3.connect('dna_records.db')
        cursor = conn.cursor()
        cursor.execute('''
            INSERT OR IGNORE INTO dna_records (dna, is_mutant) VALUES (?, ?)
        ''', (','.join(dna), is_mutant_flag))
        conn.commit()
        conn.close()

        if is_mutant_flag:
            return jsonify({'message': 'Mutant DNA detected'}), 200
        else:
            return jsonify({'message': 'Human DNA detected'}), 403
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

@app.route('/stats', methods=['GET'])
def stats():
    conn = sqlite3.connect('dna_records.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT COUNT(*) FROM dna_records WHERE is_mutant = 1
    ''')
    count_mutant_dna = cursor.fetchone()[0]

    cursor.execute('''
        SELECT COUNT(*) FROM dna_records
    ''')
    count_human_dna = cursor.fetchone()[0]

    conn.close()

    ratio = count_mutant_dna / count_human_dna if count_human_dna > 0 else 0
    return jsonify({
        'count_mutant_dna': count_mutant_dna,
        'count_human_dna': count_human_dna,
        'ratio': ratio
    })

if __name__ == "__main__":
    init_db()
    app.run(debug=True)
