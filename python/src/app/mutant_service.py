from flask import Flask, request, jsonify
import concurrent.futures

app = Flask(__name__)

class MutantDetectorLevel2:
    """
    Clase para determinar si una secuencia de ADN pertenece a un mutante con mejoras en el rendimiento.
    """
    def __init__(self, dna: list[str]):
        self.dna = dna
        self.size = len(dna)
        self.mutant_sequences = []  # Lista para almacenar las secuencias encontradas
    
    def is_mutant(self) -> bool:
        """
        Determina si un ADN corresponde a un mutante.

        Returns:
            bool: True si es mutante, False si no lo es
        """
        try:
            sequences_found = 0

            with concurrent.futures.ThreadPoolExecutor() as executor:
                futures = []
                for i in range(self.size):
                    for j in range(self.size):
                        if self.dna[i][j] not in ['A', 'T', 'C', 'G']:
                            raise ValueError(f"Carácter inválido en la secuencia de ADN: {self.dna[i][j]}")
                        # Ejecutar verificaciones en paralelo
                        futures.append(executor.submit(self._check_sequence, i, j, 0, 1))
                        futures.append(executor.submit(self._check_sequence, i, j, 1, 0))
                        futures.append(executor.submit(self._check_sequence, i, j, 1, 1))
                        futures.append(executor.submit(self._check_sequence, i, j, 1, -1))
                
                for future in concurrent.futures.as_completed(futures):
                    if future.result():
                        sequences_found += 1
                        if sequences_found > 1:
                            return True

            return False
        except Exception as e:
            raise RuntimeError("Error determinando si es mutante: " + str(e)) from e

    def _check_sequence(self, row: int, col: int, dx: int, dy: int) -> bool:
        """
        Verifica si hay una secuencia de cuatro letras iguales en la dirección especificada.

        Args:
            row (int): Fila inicial de la secuencia.
            col (int): Columna inicial de la secuencia.
            dx (int): Desplazamiento en el eje X.
            dy (int): Desplazamiento en el eje Y.

        Returns:
            bool: True si se encuentra una secuencia de cuatro letras iguales, False en caso contrario.
        """
        try:
            if not (0 <= row + 3 * dx < self.size and 0 <= col + 3 * dy < self.size):
                return False

            letter = self.dna[row][col]
            if letter not in ['A', 'T', 'C', 'G']:
                return False

            for i in range(1, 4):
                if self.dna[row + i * dx][col + i * dy] != letter:
                    return False
            # Si se encuentra una secuencia válida, la agregamos a la lista
            self.mutant_sequences.append((row, col, dx, dy, letter))
            return True
        except IndexError as e:
            raise IndexError("Índice fuera de rango al verificar la secuencia: " + str(e)) from e
        except Exception as e:
            raise RuntimeError("Error desconocido al verificar la secuencia: " + str(e)) from e

@app.route('/mutant/', methods=['POST'])
def mutant():
    try:
        data = request.get_json()
        if 'dna' not in data:
            return jsonify({"error": "Falta el parámetro 'dna'"}), 400

        dna = data['dna']
        detector = MutantDetectorLevel2(dna)
        is_mutant = detector.is_mutant()

        if is_mutant:
            return "Mutant detected", 200
        else:
            return "Forbidden", 403
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    try:
        # Ejecutar la API en localhost:5000
        app.run(host='0.0.0.0', port=5000, debug=True)
    except RuntimeError as e:
        print(e)
