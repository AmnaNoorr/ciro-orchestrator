# agents/reasoning_agent.py
# Layer 3 — Reasoning & Situation Analysis Agent
# Input:  crisis candidate from detection_agent
# Output: full crisis object matching crises.json schema

import re
import os
import uuid
import requests
from datetime import datetime, timezone
from services.groq_service import reason
from dotenv import load_dotenv

load_dotenv()


def geocode_location(location: str) -> dict | None:
    """
    Converts any location string to lat/lng using Google Maps Geocoding API.
    Appends 'Pakistan' to improve accuracy.
    Returns None if API key missing or location not found.
    """
    api_key = os.getenv("GOOGLE_MAPS_API_KEY")
    if not api_key:
        return None

    try:
        url = "https://maps.googleapis.com/maps/api/geocode/json"
        params = {
            "address": f"{location}, Pakistan",
            "key": api_key,
            "region": "pk"
        }
        response = requests.get(url, params=params, timeout=5)
        data = response.json()

        if data.get("status") == "OK" and data.get("results"):
            loc = data["results"][0]["geometry"]["location"]
            return {"lat": loc["lat"], "lng": loc["lng"]}
    except Exception as e:
        print(f"Geocoding failed: {e}")

    return None


def analyze(crisis_candidate: dict) -> dict:
    """
    Calls LLM for reasoning and assembles full crisis object
    matching the crises.json schema exactly.
    Geocodes location dynamically — no hardcoded coordinates.
    """
    llm_output = reason(crisis_candidate)

    crisis_id = "c-" + str(uuid.uuid4())[:8]
    location = crisis_candidate["location"]

    # Get real coordinates via Google Maps Geocoding API
    coordinates = geocode_location(location)

    # If geocoding fails (no key or unknown location), return null coords
    if coordinates is None:
        coordinates = {"lat": None, "lng": None}

    crisis_object = {
        "id": crisis_id,
        "type": llm_output.get("type", "Urban Flooding"),
        "location": location,
        "coordinates": coordinates,
        "severity": llm_output.get("severity", crisis_candidate["severity"]),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "description": llm_output.get("description", ""),
        "confidence": llm_output.get("confidence", 0.85),
        "impacts": llm_output.get("impacts", []),
        "recommendedActions": llm_output.get("recommendedActions", []),
        "explanation": llm_output.get("explanation", "")
    }

    return crisis_object