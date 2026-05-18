# agents/detection_agent.py
# Layer 2 — Event Detection Agent
# Input:  normalized signal from signal_agent
# Output: crisis candidate dict with severity

# --- Inline mock data (simulated APIs) ---
def get_weather_data(location: str) -> dict:
    """Simulated weather API response"""
    return {
        "rainfall_mm": 74,
        "alert": "Heavy Rain Warning",
        "threshold_exceeded": True,  # threshold is 50mm
        "location": location
    }

def get_traffic_data(location: str) -> dict:
    """Simulated traffic/maps API response"""
    return {
        "congestion_level": "SEVERE",
        "spike_percent": 340,
        "affected_roads": ["Jinnah Avenue", "Faizabad Interchange"],
        "location": location
    }

# --- Thresholds ---
KEYWORD_THRESHOLD = 2        # min keywords to flag crisis
RAINFALL_THRESHOLD = 50      # mm/hr
CONGESTION_THRESHOLD = 200   # % spike

# --- Severity classifier ---
def classify_severity(keyword_count: int, rainfall_mm: int, congestion_spike: int) -> str:
    score = 0
    if keyword_count >= 4:
        score += 3
    elif keyword_count >= 2:
        score += 2
    else:
        score += 1

    if rainfall_mm > 70:
        score += 3
    elif rainfall_mm > 50:
        score += 2

    if congestion_spike > 300:
        score += 2
    elif congestion_spike > 200:
        score += 1

    if score >= 7:
        return "HIGH"
    elif score >= 4:
        return "MEDIUM"
    else:
        return "LOW"


def detect(normalized_signal: dict) -> dict:
    """
    Cross-references citizen signal with weather + traffic.
    Returns a crisis candidate dict if threshold exceeded.
    """
    location = normalized_signal["location"]
    keyword_count = normalized_signal["keyword_count"]
    crisis_hint = normalized_signal["crisis_hint"]

    # Get simulated external data
    weather = get_weather_data(location)
    traffic = get_traffic_data(location)

    # Check if signal crosses detection threshold
    is_crisis = (
        keyword_count >= KEYWORD_THRESHOLD and
        weather["threshold_exceeded"]
    )

    severity = classify_severity(
        keyword_count,
        weather["rainfall_mm"],
        traffic["spike_percent"]
    )

    crisis_candidate = {
        "is_crisis": is_crisis,
        "crisis_hint": crisis_hint,
        "location": location,
        "severity": severity,
        "weather": weather,
        "traffic": traffic,
        "signal": normalized_signal,
        "detection_notes": (
            f"Found {keyword_count} flood keywords. "
            f"Rainfall: {weather['rainfall_mm']}mm/hr. "
            f"Traffic spike: {traffic['spike_percent']}%."
        )
    }

    return crisis_candidate