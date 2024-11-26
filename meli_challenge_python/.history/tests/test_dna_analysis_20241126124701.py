import pytest
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))
from dna_analysis import check_sequence, extract_diagonals, is_mutant

def test_check_sequence():
    assert check_sequence("AAAAG") == True
    assert check_sequence("AAGGTT") == False
    assert check_sequence("CCCC") == True
    assert check_sequence("ATCGATCG") == False

def test_extract_diagonals():
    dna = [
        "ATCG",
        "TAGC",
        "CGTA",
        "GCAT"
    ]
    expected_diagonals = [
        "A", "TC", "AGT", "CGTA", "GCA", "T", "C", 
        "G", "TG", "ACT", "CGTA", "GAC", "T", "A"
    ]
    assert extract_diagonals(dna) == expected_diagonals

def test_is_mutant():
    dna_mutant = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA",
        "TCACTG"
    ]
    dna_non_mutant = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "TCCCTA",
        "TCACTG"
    ]
    dna_invalid = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "TCCCTA"
    ]
    dna_invalid_chars = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "TCCCTA",
        "TCACTX"
    ]

    assert is_mutant(dna_mutant) == True
    assert is_mutant(dna_non_mutant) == False

    with pytest.raises(ValueError):
        is_mutant(dna_invalid)

    with pytest.raises(ValueError):
        is_mutant(dna_invalid_chars)

if __name__ == "__main__":
    pytest.main()