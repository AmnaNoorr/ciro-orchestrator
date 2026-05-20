# agents/detection_agent.py
# Layer 2 — Event Detection Agent
# Input:  normalized signal from signal_agent
# Output: crisis candidate dict with severity

import random

KEYWORD_THRESHOLD = 2
RAINFALL_THRESHOLD = 50
CONGESTION_THRESHOLD = 200


def get_weather_data(location: str) -> dict:
    """Simulated weather API — rainfall varies by region"""
    location_upper = location.upper()

    if any(c in location_upper for c in ["KARACHI", "HYDERABAD", "SUKKUR", "LARKANA"]):
        rainfall = random.randint(65, 90)
    elif any(c in location_upper for c in ["SWAT", "ABBOTTABAD", "GILGIT", "MUZAFFARABAD"]):
        rainfall = random.randint(70, 95)
    elif any(c in location_upper for c in ["LAHORE", "FAISALABAD", "GUJRANWALA", "SIALKOT"]):
        rainfall = random.randint(55, 85)
    elif any(c in location_upper for c in ["ISLAMABAD", "RAWALPINDI", "PESHAWAR"]):
        rainfall = random.randint(55, 80)
    elif any(c in location_upper for c in ["QUETTA", "MULTAN", "BAHAWALPUR"]):
        rainfall = random.randint(30, 65)
    else:
        rainfall = random.randint(40, 80)

    return {
        "rainfall_mm": rainfall,
        "alert": "Heavy Rain Warning" if rainfall > 50 else "Moderate Rain Advisory",
        "threshold_exceeded": rainfall > RAINFALL_THRESHOLD,
        "location": location
    }


def get_traffic_data(location: str) -> dict:
    """Simulated traffic API — congestion varies by city density"""
    location_upper = location.upper()

    if any(c in location_upper for c in ["KARACHI", "LAHORE"]):
        spike = random.randint(280, 420)
        roads = ["Shahrae Faisal", "MM Alam Road", "Main Boulevard", "Korangi Road"]
    elif any(c in location_upper for c in ["ISLAMABAD", "RAWALPINDI"]):
        spike = random.randint(200, 360)
        roads = ["Jinnah Avenue", "Faizabad Interchange", "Kashmir Highway", "Murree Road"]
    elif any(c in location_upper for c in ["PESHAWAR", "FAISALABAD", "GUJRANWALA"]):
        spike = random.randint(150, 300)
        roads = ["GT Road", "Ring Road", "Canal Road"]
    elif any(c in location_upper for c in ["MULTAN", "BAHAWALPUR", "SARGODHA"]):
        spike = random.randint(120, 260)
        roads = ["Bosan Road", "Nusrat Road", "Bypass Road"]
    elif any(c in location_upper for c in ["QUETTA", "ABBOTTABAD", "SWAT"]):
        spike = random.randint(100, 240)
        roads = ["Saryab Road", "Mansehra Road", "Main Bazaar Road"]
    else:
        spike = random.randint(100, 280)
        roads = ["Main Road", "Bypass Road", "City Road"]

    return {
        "congestion_level": "SEVERE" if spike > 300 else "HIGH" if spike > 200 else "MODERATE",
        "spike_percent": spike,
        "affected_roads": roads,
        "location": location
    }


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
    location = normalized_signal["location"]
    keyword_count = normalized_signal["keyword_count"]
    crisis_hint = normalized_signal["crisis_hint"]

    weather = get_weather_data(location)
    traffic = get_traffic_data(location)

    is_crisis = (
        keyword_count >= KEYWORD_THRESHOLD or
        weather["threshold_exceeded"] or
        traffic["spike_percent"] > CONGESTION_THRESHOLD
    )

    severity = classify_severity(
        keyword_count,
        weather["rainfall_mm"],
        traffic["spike_percent"]
    )

    return {
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