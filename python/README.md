# Mutant Detector API

This project implements a service to detect mutant DNA sequences based on specific patterns within a DNA matrix. It includes a REST API for verifying if a DNA sequence belongs to a mutant and provides statistics on the ratio of mutants to humans.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Testing](#testing)
- [Deployment](#deployment)

## Features
1. **Mutant Detection**: Identifies if a DNA sequence belongs to a mutant.
2. **REST API**: Exposes endpoints for mutation detection and statistics retrieval.
3. **Statistics**: Tracks the ratio of mutants to human DNA sequences.
4. **Database Storage**: Records each unique DNA sequence for future reference.

## Requirements
- Python 3.8+
- FastAPI

## Setup

### 1. Clone the Repository
```bash
git clone https://github.com/federiconbaez/meli-challenge.git mutant-detector
cd mutant-detector

### 2. Create a Virtual Environment and Install Dependencies
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

### 3. Ejecutar
uvicorn main:app --reload

