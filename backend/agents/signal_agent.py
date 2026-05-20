# agents/signal_agent.py
# Layer 1 — Ingestion & Normalization Agent
# Input:  raw POST body from /ingest
# Output: normalized signal dict

from datetime import datetime, timezone

FLOOD_KEYWORDS = [
    "pani", "bhar", "sailaab", "doob", "naala", "barish", "baarish",
    "flood", "waterlog", "submerged", "overflow", "drain", "blocked",
    "paani", "gehra", "pani bhar", "pani aa", "sailab", "toofan",
    "tez baarish", "heavy rain", "flash flood", "waterlogging",
    "gharka", "duba", "dubi", "doob gaya", "pani chadh", "selab",
    "baarish ho rahi", "pani jama", "rasta band", "sadak band"
]


def normalize(raw_input: dict) -> dict:
    text = raw_input.get("text", "").lower()
    language = raw_input.get("language", "en")
    photo_url = raw_input.get("photo_url", None)

    # Use location exactly as provided — no hardcoded list
    location = raw_input.get("location", "").strip()
    if not location:
        location = "Unknown"

    # Extract flood keywords from text
    found_keywords = [kw for kw in FLOOD_KEYWORDS if kw in text]

    crisis_hint = "urban_flooding" if found_keywords else "unknown"

    return {
        "original_text": raw_input.get("text", ""),
        "cleaned_text": text,
        "language": language,
        "location": location,
        "photo_url": photo_url,
        "found_keywords": found_keywords,
        "crisis_hint": crisis_hint,
        "keyword_count": len(found_keywords),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "source": "citizen_report"
    }