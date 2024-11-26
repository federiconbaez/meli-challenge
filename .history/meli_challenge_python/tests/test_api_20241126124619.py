import pytest
from flask import json
from api import app, init_db

@pytest.fixture
def client():
    init_db()
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_mutant_endpoint_with_mutant_dna(client):
    response = client.post('/mutant/', json={
        'dna': ["ATGCGA", "CAGTGC", "TTATGT", "AGAAGG", "CCCCTA", "TCACTG"]
    })
    assert response.status_code == 200
    assert response.get_json() == {'message': 'Mutant DNA detected'}

def test_mutant_endpoint_with_human_dna(client):
    response = client.post('/mutant/', json={
        'dna': ["ATGCGA", "CAGTGC", "TTATTT", "AGACGG", "GCGTCA", "TCACTG"]
    })
    assert response.status_code == 403
    assert response.get_json() == {'message': 'Human DNA detected'}

def test_mutant_endpoint_with_invalid_dna(client):
    response = client.post('/mutant/', json={
        'dna': "invalid_dna"
    })
    assert response.status_code == 400
    assert response.get_json() == {'error': 'DNA must be a list of strings'}

def test_mutant_endpoint_with_missing_dna(client):
    response = client.post('/mutant/', json={})
    assert response.status_code == 400
    assert response.get_json() == {'error': 'Missing DNA data'}

def test_stats_endpoint(client):
    # Insert some test data
    client.post('/mutant/', json={
        'dna': ["ATGCGA", "CAGTGC", "TTATGT", "AGAAGG", "CCCCTA", "TCACTG"]
    })
    client.post('/mutant/', json={
        'dna': ["ATGCGA", "CAGTGC", "TTATTT", "AGACGG", "GCGTCA", "TCACTG"]
    })

    response = client.get('/stats')
    data = response.get_json()
    assert response.status_code == 200
    assert 'count_mutant_dna' in data
    assert 'count_human_dna' in data
    assert 'ratio' in data