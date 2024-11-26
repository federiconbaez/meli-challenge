package com.mercadolibre;

import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

public class MutantDetectorTest {

    @Test
    public void testIsMutantWithMutantDNA() {
        String[] dna = {
            "ATGCGA",
            "CAGTGC",
            "TTATGT",
            "AGAAGG",
            "CCCCTA",
            "TCACTG"
        };
        MutantDetector detector = new MutantDetector(dna);
        assertTrue(detector.isMutant(), "The DNA should be identified as mutant");
    }

    @Test
    public void testIsMutantWithNonMutantDNA() {
        String[] dna = {
            "ATGCGA",
            "CAGTGC",
            "TTATTT",
            "AGACGG",
            "GCGTCA",
            "TCACTG"
        };
        MutantDetector detector = new MutantDetector(dna);
        assertFalse(detector.isMutant(), "The DNA should not be identified as mutant");
    }

    @Test
    public void testIsMutantWithEmptyDNA() {
        String[] dna = {};
        MutantDetector detector = new MutantDetector(dna);
        assertFalse(detector.isMutant(), "Empty DNA should not be identified as mutant");
    }

    @Test
    public void testIsMutantWithSingleElementDNA() {
        String[] dna = {"A"};
        MutantDetector detector = new MutantDetector(dna);
        assertFalse(detector.isMutant(), "Single element DNA should not be identified as mutant");
    }
}
