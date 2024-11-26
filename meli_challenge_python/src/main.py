# -----------------------------------------------------------------------------------------------------
# @ Import Section
# -----------------------------------------------------------------------------------------------------
from typing import List

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
    for k in range(-(n-1), n):
        diagonal = []
        for i in range(n):
            j = i - k
            if 0 <= j < n:
                diagonal.append(dna[i][j])
        if len(diagonal) >= 4:
            diagonals.append(''.join(diagonal))

    # Top-right to bottom-left diagonals
    for k in range(-(n-1), n):
        diagonal = []
        for i in range(n):
            j = n - 1 - i - k
            if 0 <= j < n:
                diagonal.append(dna[i][j])
        if len(diagonal) >= 4:
            diagonals.append(''.join(diagonal))

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

def main():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA",
        "TCACTG"
    ]
    print(is_mutant(dna_sample))  # Expected output: True

# -----------------------------------------------------------------------------------------------------
# @ Entry Point Section
# -----------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    try:
        dna_sample = [
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        ]
        
        print(is_mutant(dna_sample))  # Expected output: True
    except ValueError as e:
        print(f"Input Error: {e}")
