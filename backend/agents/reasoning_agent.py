# agents/reasoning_agent.py
# Layer 3 — Reasoning & Situation Analysis Agent
# Input:  crisis candidate from detection_agent
# Output: full crisis object matching crises.json schema

import uuid
from datetime import datetime, timezone
from services.groq_service import reason

# Coordinates lookup for known Pakistan locations
LOCATION_COORDINATES = {
    "G-10": {"lat": 33.6670, "lng": 72.9911},
    "G-9":  {"lat": 33.6750, "lng": 72.9850},
    "G-8":  {"lat": 33.6830, "lng": 72.9800},
    "F-8":  {"lat": 33.7080, "lng": 73.0480},
    "ISLAMABAD": {"lat": 33.6844, "lng": 73.0479},
    "RAWALPINDI": {"lat": 33.5651, "lng": 73.0169},
    "FAIZABAD": {"lat": 33.6938, "lng": 73.0595},
    "BLUE AREA": {"lat": 33.7086, "lng": 73.0450},
}

def get_coordinates(location: str) -> dict:
    for key, coords in LOCATION_COORDINATES.items():
        if key in location.upper():
            return coords
    # Default to Islamabad center
    return {"lat": 33.6844, "lng": 73.0479}


def analyze(crisis_candidate: dict) -> dict:
    """
    Calls Gemini for reasoning and assembles full crisis object
    matching the crises.json schema exactly.
    """
    # Call Gemini
    gemini_output = reason(crisis_candidate)

    # Generate unique crisis ID
    crisis_id = "c-" + str(uuid.uuid4())[:8]

    # Get coordinates
    location = crisis_candidate["location"]
    coordinates = get_coordinates(location)

    # Assemble final crisis object — matches crises.json exactly
    crisis_object = {
        "id": crisis_id,
        "type": gemini_output.get("type", "Urban Flooding"),
        "location": location,
        "coordinates": coordinates,
        "severity": gemini_output.get("severity", crisis_candidate["severity"]),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "description": gemini_output.get("description", ""),
        "confidence": gemini_output.get("confidence", 0.85),
        "impacts": gemini_output.get("impacts", []),
        "recommendedActions": gemini_output.get("recommendedActions", []),
        "explanation": gemini_output.get("explanation", "")
    }

    return crisis_object