import pytest
import sys
import os
import random

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))
from dna_analysis import check_sequence, extract_diagonals, is_mutant

def test_check_sequence():
    """
    Comprehensive test cases for check_sequence function
    """
    # Positive cases
    assert check_sequence("AAAAG") is True
    assert check_sequence("CCCC") is True
    assert check_sequence("GGGG") is True
    assert check_sequence("TTTT") is True

    # Negative cases
    assert check_sequence("ATCG") is False
    assert check_sequence("AAGGTT") is False
    assert check_sequence("ATCGATCG") is False

    # Edge cases
    assert check_sequence("AAAA") is True
    assert check_sequence("A") is False

    # Invalid input cases
    with pytest.raises(ValueError, match="Invalid DNA sequence"):
        check_sequence("ATCGXATCG")
    
    with pytest.raises(ValueError, match="Invalid DNA sequence"):
        check_sequence("")
    
    with pytest.raises(ValueError, match="Invalid DNA sequence"):
        check_sequence(None)

def test_extract_diagonals():
    """
    Comprehensive test cases for extract_diagonals function
    """
    # Standard square matrix
    dna = [
        "ATCG",
        "TAGC",
        "CGTA",
        "GCAT"
    ]
    expected_diagonals = [
        "A", "TG", "CGA", "TGC", "GTA", "C",
        "T", "AG", "CTA", "GAT", "GC", "A"
    ]
    assert set(extract_diagonals(dna)) == set(expected_diagonals)

    # Edge cases
    # Single row matrix
    single_row = ["ATCG"]
    with pytest.raises(ValueError, match="DNA matrix must be square"):
        extract_diagonals(single_row)

    # Empty matrix
    with pytest.raises(ValueError, match="DNA matrix cannot be empty"):
        extract_diagonals([])

    # Non-square matrix
    non_square = [
        "ATCG",
        "TAGC",
        "CGTA"
    ]
    with pytest.raises(ValueError, match="DNA matrix must be square"):
        extract_diagonals(non_square)

    # Matrix with different length rows
    unequal_rows = [
        "ATCG",
        "TAGCX",
        "CGTA",
        "GCAT"
    ]
    with pytest.raises(ValueError, match="All rows must have equal length"):
        extract_diagonals(unequal_rows)

def test_is_mutant():
    """
    Comprehensive test cases for is_mutant function
    """
    # Confirmed mutant DNA sequences
    mutant_cases = [
        # Horizontal matches
        [
            "AAAA",
            "CCCC",
            "GGGG",
            "TTTT"
        ],
        # Vertical matches
        [
            "ABCD",
            "ABCD",
            "ABCD",
            "ABCD"
        ],
        # Diagonal matches
        [
            "ATGC",
            "CTAG",
            "GATC",
            "TCGA"
        ]
    ]

    # Confirmed non-mutant DNA sequences
    non_mutant_cases = [
        [
            "ATGC",
            "CAGT",
            "TTAT",
            "AGAA"
        ],
        [
            "ABCD",
            "EFGH",
            "IJKL",
            "MNOP"
        ]
    ]

    # Test mutant cases
    for mutant_dna in mutant_cases:
        assert is_mutant(mutant_dna) is True, f"Failed to identify mutant DNA: {mutant_dna}"

    # Test non-mutant cases
    for non_mutant_dna in non_mutant_cases:
        assert is_mutant(non_mutant_dna) is False, f"Incorrectly identified mutant DNA: {non_mutant_dna}"

    # Error cases
    # Invalid length matrix
    with pytest.raises(ValueError, match="Invalid DNA matrix"):
        is_mutant([
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "TCCCTA"
        ])

    # Invalid characters
    with pytest.raises(ValueError, match="Invalid DNA sequence"):
        is_mutant([
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "TCCCTA",
            "TCACTX"
        ])

    # Test with maximum allowed random sequence
    def generate_dna_sequence(size=6, valid_chars='ATCG'):
        return [''.join(random.choice(valid_chars) for _ in range(size)) for _ in range(size)]

    # Generate multiple random DNA sequences to ensure consistent behavior
    for _ in range(100):
        random_dna = generate_dna_sequence()
        result = is_mutant(random_dna)
        assert isinstance(result, bool), f"Invalid return type for DNA: {random_dna}"

if __name__ == "__main__":
    pytest.main()