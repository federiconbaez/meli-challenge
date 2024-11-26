# -----------------------------------------------------------------------------------------------------
# @ dna_analysis.py (DNA Analysis Logic)
# -----------------------------------------------------------------------------------------------------
from typing import List
import sqlite3

# -----------------------------------------------------------------------------------------------------
# @ Helper Function Section
# -----------------------------------------------------------------------------------------------------
def check_sequence(sequence: str) -> bool:
    """
    Checks if there is a sequence of four identical letters in a string.
    
    :param sequence: A string representing a sequence of DNA bases.
    :return: True if a sequence of four identical letters is found, False otherwise.
    """
    return any(sequence[i] == sequence[i + 1] == sequence[i + 2] == sequence[i + 3] for i in range(len(sequence) - 3))

# -----------------------------------------------------------------------------------------------------
# @ Diagonal Extraction Section
# -----------------------------------------------------------------------------------------------------
def extract_diagonals(dna: List[str]) -> List[str]:
    """
    Extracts all diagonals (both from top-left to bottom-right and top-right to bottom-left) from the DNA matrix.
    
    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: List of strings representing all diagonals.
    """
    n = len(dna)
    diagonals = []

    # Top-left to bottom-right diagonals
    for d in range(-n + 1, n):
        diagonals.append(''.join([dna[i][i - d] for i in range(max(d, 0), min(n + d, n))]))

    # Top-right to bottom-left diagonals
    for d in range(-n + 1, n):
        diagonals.append(''.join([dna[i][n - i - 1 - d] for i in range(max(d, 0), min(n + d, n))]))
    
    return diagonals

# -----------------------------------------------------------------------------------------------------
# @ Main Function Section
# -----------------------------------------------------------------------------------------------------
def is_mutant(dna: List[str]) -> bool:
    """
    Determines if the given DNA sequence belongs to a mutant by looking for more than one sequence
    of four identical letters in any direction (horizontal, vertical, diagonal).
    
    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: True if mutant, False otherwise.
    """
    # Error Handling
    if not dna or not all(isinstance(row, str) for row in dna):
        raise ValueError("DNA must be a list of strings.")
    n = len(dna)
    if any(len(row) != n for row in dna):
        raise ValueError("DNA must be a square matrix of NxN.")
    if any(char not in "ATCG" for row in dna for char in row):
        raise ValueError("DNA can only contain characters A, T, C, G.")

    sequences_found = 0

    # Horizontal and Vertical Checks
    for row in dna:
        if check_sequence(row):
            sequences_found += 1
            if sequences_found > 1:
                return True
    
    for col in range(n):
        column_str = ''.join([dna[row][col] for row in range(n)])
        if check_sequence(column_str):
            sequences_found += 1
            if sequences_found > 1:
                return True

    # Diagonal Check
    diagonals = extract_diagonals(dna)
    for diagonal in diagonals:
        if check_sequence(diagonal):
            sequences_found += 1
            if sequences_found > 1:
                return True

    return False

# -----------------------------------------------------------------------------------------------------
# @ Database Section
# -----------------------------------------------------------------------------------------------------
def init_db():
    conn = sqlite3.connect('dna_records.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS dna_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dna TEXT NOT NULL UNIQUE,
            is_mutant BOOLEAN NOT NULL
        )
    ''')
    conn.commit()
    conn.close()
