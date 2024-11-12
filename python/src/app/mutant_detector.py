from PyQt6 import QtWidgets, uic
import sys

class MutantDetector:
    """
    Clase para determinar si una secuencia de ADN pertenece a un mutante.
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

            for i in range(self.size):
                for j in range(self.size):
                    if self._check_sequence(i, j, 0, 1) or \
                       self._check_sequence(i, j, 1, 0) or \
                       self._check_sequence(i, j, 1, 1) or \
                       self._check_sequence(i, j, 1, -1):
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

class MutantDetectorApp(QtWidgets.QMainWindow):
    def __init__(self):
        super(MutantDetectorApp, self).__init__()
        self.setWindowTitle("Detector de Mutantes")
        self.setGeometry(100, 100, 400, 400)

        # Widget de entrada de ADN
        self.dna_input = QtWidgets.QPlainTextEdit(self)
        self.dna_input.setPlaceholderText("Ingrese secuencia de ADN, cada fila separada por una nueva línea...")
        self.dna_input.setGeometry(50, 50, 300, 100)

        # Botón para analizar
        self.analyze_button = QtWidgets.QPushButton("Analizar", self)
        self.analyze_button.setGeometry(150, 170, 100, 30)
        self.analyze_button.clicked.connect(self.analyze_dna)

        # Etiqueta de resultado
        self.result_label = QtWidgets.QLabel("", self)
        self.result_label.setGeometry(50, 220, 300, 40)

        # Etiqueta de secuencias encontradas
        self.sequences_label = QtWidgets.QLabel("", self)
        self.sequences_label.setGeometry(50, 270, 300, 100)
        self.sequences_label.setWordWrap(True)

    def analyze_dna(self):
        dna_text = self.dna_input.toPlainText().splitlines()
        try:
            # Filtrar secuencias vacías
            dna_text = [line.strip().upper() for line in dna_text if line.strip()]
            detector = MutantDetector(dna_text)
            is_mutant = detector.is_mutant()
            self.result_label.setText(f"¿Es mutante? {'Sí' if is_mutant else 'No'}")

            # Mostrar las secuencias encontradas si las hay
            if detector.mutant_sequences:
                sequences_info = "\n".join([
                    f"Secuencia en ({row}, {col}) dirección ({dx}, {dy}) con letra '{letter}'"
                    for row, col, dx, dy, letter in detector.mutant_sequences
                ])
                self.sequences_label.setText(f"Secuencias encontradas:\n{sequences_info}")
            else:
                self.sequences_label.setText("No se encontraron secuencias de mutante.")
        except Exception as e:
            self.result_label.setText(f"Error: {str(e)}")
            self.sequences_label.setText("")

if __name__ == "__main__":
    try:
        adn = [
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        ]
        detector = MutantDetector(adn)
        es_mutante = detector.is_mutant()
        print(f"¿Es mutante? {es_mutante}")

        if detector.mutant_sequences:
            for seq in detector.mutant_sequences:
                row, col, dx, dy, letter = seq
                print(f"Secuencia en ({row}, {col}) dirección ({dx}, {dy}) con letra '{letter}'")

        app = QtWidgets.QApplication(sys.argv)
        window = MutantDetectorApp()
        window.show()
        sys.exit(app.exec())
    except RuntimeError as e:
        print(e)