import pytest
import pytest
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))
from main import main
from main import is_mutant

def test_main():
    """Simple test to ensure main function runs without error."""
    try:
        main()
    except Exception as e:
        pytest.fail(f"main() raised {type(e).__name__} unexpectedly!")

def test_is_mutant_with_mutant_dna():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA",
        "TCACTG"
    ]
    assert is_mutant(dna_sample) == True

def test_is_mutant_with_non_mutant_dna():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATTT",
        "AGACGG",
        "GCGTCA",
        "TCACTG"
    ]
    assert is_mutant(dna_sample) == False

def test_is_mutant_with_invalid_dna_non_square():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA"
    ]
    with pytest.raises(ValueError, match="DNA must be a square matrix of NxN."):
        is_mutant(dna_sample)

def test_is_mutant_with_invalid_dna_non_string():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        123456,
        "CCCCTA",
        "TCACTG"
    ]
    with pytest.raises(ValueError, match="DNA must be a list of strings."):
        is_mutant(dna_sample)

def test_is_mutant_with_invalid_dna_invalid_characters():
    dna_sample = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCXTA",
        "TCACTG"
    ]
    with pytest.raises(ValueError, match="DNA can only contain characters A, T, C, G."):
        is_mutant(dna_sample)
