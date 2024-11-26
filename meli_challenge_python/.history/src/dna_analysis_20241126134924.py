import logging
from typing import List
import sqlite3
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s: %(message)s',
    filename='dna_analysis.log'
)
logger = logging.getLogger(__name__)

def check_sequence(sequence: str) -> bool:
    """
    Checks if there is a sequence of four identical letters in a string.
    
    :param sequence: A string representing a sequence of DNA bases.
    :return: True if a sequence of four identical letters is found, False otherwise.
    """
    try:
        return any(sequence[i] == sequence[i + 1] == sequence[i + 2] == sequence[i + 3] for i in range(len(sequence) - 3))
    except Exception as e:
        logger.error(f"Error in check_sequence: {e}")
        raise

def extract_diagonals(dna: List[str]) -> List[str]:
    """
    Extracts all diagonals (both from top-left to bottom-right and top-right to bottom-left) from the DNA matrix.

    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: List of strings representing all diagonals.
    """
    try:
        n = len(dna)
        if n == 0:
            raise ValueError("DNA matrix cannot be empty")

        for row in dna:
            if len(row) != n:
                raise ValueError("All rows in the DNA matrix must have the same length")

        diagonals = []

        # Top-left to bottom-right diagonals
        for d in range(-n + 1, n):
            diagonal = ""
            for i in range(max(d, 0), min(n, n + d)):
                if 0 <= i - d < n:
                    diagonal += dna[i][i - d]
            diagonals.append(diagonal)

        # Top-right to bottom-left diagonals
        for d in range(-n + 1, n):
            diagonal = ""
            for i in range(max(d, 0), min(n, n + d)):
                if 0 <= n - 1 - i - d < n:
                    diagonal += dna[i][n - 1 - i - d]
            diagonals.append(diagonal)

        return diagonals
    except Exception as e:
        logger.error(f"Error in extract_diagonals: {e}")
        raise

def is_mutant(dna: List[str]) -> bool:
    """
    Determines if the given DNA sequence belongs to a mutant by looking for more than one sequence
    of four identical letters in any direction (horizontal, vertical, diagonal).
    
    :param dna: List of strings representing each row of an NxN DNA sequence table.
    :return: True if mutant, False otherwise.
    """
    try:
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
                    logger.info(f"Mutant detected - Horizontal match found: {row}")
                    return True
        
        for col in range(n):
            column_str = ''.join([dna[row][col] for row in range(n)])
            if check_sequence(column_str):
                sequences_found += 1
                if sequences_found > 1:
                    logger.info(f"Mutant detected - Vertical match found: {column_str}")
                    return True

        # Diagonal Check
        diagonals = extract_diagonals(dna)
        for diagonal in diagonals:
            if check_sequence(diagonal):
                sequences_found += 1
                if sequences_found > 1:
                    logger.info(f"Mutant detected - Diagonal match found: {diagonal}")
                    return True

        logger.info(f"Non-mutant DNA sequence: No repeated 4-letter sequences")
        return False
    except Exception as e:
        logger.error(f"Error analyzing DNA sequence: {e}")
        raise

def init_db():
    """
    Initialize the database with a more robust setup and additional fields
    """
    try:
        conn = sqlite3.connect('dna_records.db')
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS dna_records (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                dna TEXT NOT NULL UNIQUE,
                is_mutant BOOLEAN NOT NULL,
                detected_at DATETIME NOT NULL,
                sequences_discovered TEXT
            )
        ''')
        conn.commit()
        conn.close()
        logger.info("Database initialized successfully")
    except sqlite3.Error as e:
        logger.error(f"Database initialization error: {e}")
        raise

def record_dna_analysis(dna: List[str], is_mutant_result: bool):
    """
    Record the DNA analysis results in the database
    """
    try:
        dna_str = ''.join(dna)
        conn = sqlite3.connect('dna_records.db')
        cursor = conn.cursor()
        cursor.execute('''
            INSERT OR IGNORE INTO dna_records 
            (dna, is_mutant, detected_at, sequences_discovered) 
            VALUES (?, ?, ?, ?)
        ''', (
            dna_str, 
            is_mutant_result, 
            datetime.now(),
            str(extract_diagonals(dna)) if is_mutant_result else None
        ))
        conn.commit()
        conn.close()
        logger.info(f"DNA record {'mutant' if is_mutant_result else 'non-mutant'} saved")
    except sqlite3.IntegrityError:
        logger.warning(f"DNA sequence {dna_str} already exists in database")
    except Exception as e:
        logger.error(f"Error recording DNA analysis: {e}")
        raise