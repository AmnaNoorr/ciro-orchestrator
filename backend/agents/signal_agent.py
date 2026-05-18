# agents/signal_agent.py
# Layer 1 — Ingestion & Normalization Agent
# Input:  raw POST body from /ingest
# Output: normalized signal dict

import re
from datetime import datetime, timezone

# Urdu/Roman Urdu flood keyword map
FLOOD_KEYWORDS = [
    "pani", "bhar", "sailaab", "doob", "naala", "barish", "baarish",
    "flood", "waterlog", "submerged", "overflow", "drain", "blocked",
    "paani", "gehra", "gehr", "pani bhar", "pani aa"
]

LOCATION_HINTS = [
    "g-10", "g-9", "g-8", "f-8", "f-7", "i-8", "i-10",
    "rawalpindi", "islamabad", "faizabad", "kachehri",
    "blue area", "george town", "saddar"
]


def normalize(raw_input: dict) -> dict:
    """
    Takes raw input from Flutter signal_input_screen and returns
    a clean normalized signal dict for the detection agent.
    """
    text = raw_input.get("text", "").lower()
    location = raw_input.get("location", "Unknown")
    language = raw_input.get("language", "en")
    photo_url = raw_input.get("photo_url", None)

    # Extract keywords found in text
    found_keywords = [kw for kw in FLOOD_KEYWORDS if kw in text]

    # Try to extract location from text if not provided
    detected_location = location
    for hint in LOCATION_HINTS:
        if hint in text:
            detected_location = hint.upper()
            break

    # Determine crisis type hint from keywords
    crisis_hint = "unknown"
    if found_keywords:
        crisis_hint = "urban_flooding"

    normalized = {
        "original_text": raw_input.get("text", ""),
        "cleaned_text": text,
        "language": language,
        "location": detected_location,
        "photo_url": photo_url,
        "found_keywords": found_keywords,
        "crisis_hint": crisis_hint,
        "keyword_count": len(found_keywords),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "source": "citizen_report"
    }

    return normalized