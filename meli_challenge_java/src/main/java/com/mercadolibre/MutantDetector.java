package com.mercadolibre;

public class MutantDetector {

    private String[] dna;
    private int size;

    public MutantDetector(String[] dna) {
        this.dna = dna;
        this.size = dna.length;
    }

    public boolean isMutant() {
        int sequencesFound = 0;

        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (checkSequence(i, j, 0, 1) ||  // Horizontal
                    checkSequence(i, j, 1, 0) ||  // Vertical
                    checkSequence(i, j, 1, 1) ||  // Diagonal hacia abajo a la derecha
                    checkSequence(i, j, 1, -1)) { // Diagonal hacia abajo a la izquierda
                    sequencesFound++;
                    if (sequencesFound > 1) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private boolean checkSequence(int row, int col, int dx, int dy) {
        if (row + 3 * dx >= size || row + 3 * dx < 0 || col + 3 * dy >= size || col + 3 * dy < 0) {
            return false;
        }

        char letter = dna[row].charAt(col);
        for (int i = 1; i < 4; i++) {
            if (dna[row + i * dx].charAt(col + i * dy) != letter) {
                return false;
            }
        }
        return true;
    }

    public static void main(String[] args) {
        String[] adn = {
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        };
        MutantDetector detector = new MutantDetector(adn);
        boolean esMutante = detector.isMutant();
        System.out.println("¿Es mutante? " + esMutante);
    }
}
