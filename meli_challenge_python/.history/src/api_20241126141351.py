import os
import logging
from logging.handlers import RotatingFileHandler
import sqlite3
from flask import Flask, request, jsonify
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_cors import CORS
import json
from datetime import datetime

# Import from local modules
from dna_analysis import is_mutant, init_db, record_dna_analysis

# Configure logging
def setup_logging(app):
    """
    Set up logging configuration for the application
    """
    # Ensure logs directory exists
    os.makedirs('logs', exist_ok=True)
    
    # Configure file handler
    file_handler = RotatingFileHandler(
        'logs/mutant_api.log', 
        maxBytes=10 * 1024 * 1024,  # 10 MB
        backupCount=5
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s - %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)

    # Add handler to app logger
    app.logger.addHandler(file_handler)
    app.logger.setLevel(logging.INFO)

    # Log startup
    app.logger.info("Mutant Detection API starting up")

# Create Flask app with enhanced configuration
def create_app():
    app = Flask(__name__)
    
    # CORS configuration
    CORS(app, resources={
        r"/mutant/": {"origins": "*"},
        r"/stats": {"origins": "*"}
    })

    # Rate limiting configuration
    limiter = Limiter(
        app=app,
        key_func=get_remote_address,
        default_limits=["100 per day", "30 per hour"],
        storage_uri="memory://"
    )

    # Logging setup
    setup_logging(app)

    return app, limiter

# Initialize app and limiter
app, limiter = create_app()

@app.route('/mutant/', methods=['POST'])
@limiter.limit("10 per minute")
def mutant():
    try:
        # Validate request
        if not request.is_json:
            app.logger.warning("Non-JSON request received")
            return jsonify({'error': 'Request must be JSON'}), 400

        data = request.get_json()
        
        # Validate DNA data
        if 'dna' not in data:
            app.logger.warning("Missing DNA data in request")
            return jsonify({'error': 'Missing DNA data'}), 400

        dna = data['dna']
        
        # Validate DNA format
        if not isinstance(dna, list) or not all(isinstance(row, str) for row in dna):
            app.logger.warning(f"Invalid DNA format: {type(dna)}")
            return jsonify({'error': 'DNA must be a list of strings'}), 400

        # Analyze DNA
        try:
            is_mutant_flag = is_mutant(dna)
            
            # Record DNA analysis 
            record_dna_analysis(dna, is_mutant_flag)
            
            # Log the detection
            detection_type = "Mutant" if is_mutant_flag else "Human"
            app.logger.info(f"{detection_type} DNA detected: {json.dumps(dna)}")

            # Return appropriate response
            if is_mutant_flag:
                return jsonify({'message': 'Mutant DNA detected'}), 200
            else:
                return jsonify({'message': 'Human DNA detected'}), 403

        except ValueError as ve:
            app.logger.error(f"DNA Validation Error: {ve}")
            return jsonify({'error': str(ve)}), 400

    except Exception as e:
        app.logger.error(f"Unexpected error in /mutant/: {e}", exc_info=True)
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/stats', methods=['GET'])
@limiter.limit("30 per minute")
def stats():
    try:
        conn = sqlite3.connect('dna_records.db')
        cursor = conn.cursor()

        # Fetch mutant and human DNA counts with error handling
        cursor.execute('''
            SELECT 
                SUM(CASE WHEN is_mutant = 1 THEN 1 ELSE 0 END) as mutant_count,
                SUM(CASE WHEN is_mutant = 0 THEN 1 ELSE 0 END) as human_count
            FROM dna_records
        ''')
        
        result = cursor.fetchone()
        count_mutant_dna = result[0] or 0
        count_human_dna = result[1] or 0

        # Calculate ratio safely
        ratio = count_mutant_dna / (count_human_dna + count_mutant_dna) if (count_human_dna + count_mutant_dna) > 0 else 0

        # Log stats retrieval
        app.logger.info(f"Stats retrieved - Mutant: {count_mutant_dna}, Human: {count_human_dna}")

        conn.close()

        return jsonify({
            'count_mutant_dna': count_mutant_dna,
            'count_human_dna': count_human_dna,
            'ratio': round(ratio, 4)
        })

    except sqlite3.Error as e:
        app.logger.error(f"Database error in /stats: {e}")
        return jsonify({'error': 'Database error'}), 500
    except Exception as e:
        app.logger.error(f"Unexpected error in /stats: {e}", exc_info=True)
        return jsonify({'error': 'Internal server error'}), 500

# Application configuration and startup
if __name__ == "__main__":
    # Initialize database
    init_db()
    print("Application started successfully, listening on port 5000")


    # Run the application with enhanced configuration
    app.run(
        host='0.0.0.0',  # Listen on all network interfaces
        port=5000,
        debug=True,  # Disable debug in production
        threaded=True  # Enable threading for better performance
    )

    # List all endpoints
    with app.app_context():
        for rule in app.url_map.iter_rules():
            print(f"Endpoint: {rule.endpoint}, URL: {rule.rule}")

# Optional: Configuration for production deployment
# To be used with WSGI servers like Gunicorn
def create_production_app():
    """
    Create an app instance for production deployment
    """
    app, _ = create_app()
    return app