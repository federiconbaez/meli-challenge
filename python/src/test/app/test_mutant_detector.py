import pytest
from src.app.mutant_detector import is_mutant

def test_is_mutant_with_mutant_dna():
    mutant_dna = [
        "ATGCGA",
        "CAGTGC",
        "TTATGT",
        "AGAAGG",
        "CCCCTA",
        "TCACTG"
    ]
    assert is_mutant(mutant_dna) == True

def test_is_mutant_with_human_dna():
    human_dna = [
        "ATGCGA",
        "CAGTGC",
        "TTATTT",
        "AGACGG",
        "GCGTCA",
        "TCACTG"
    ]
    assert is_mutant(human_dna) == False
