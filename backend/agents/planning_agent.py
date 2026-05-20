# agents/planning_agent.py
# Layer 4 — Action Planning Agent
# Input:  crisis object from reasoning_agent
# Output: crisis object enriched with dispatch + reroute plan

import random

RESCUE_UNITS = [
    {"unit": "CDA Rescue Unit 4",   "type": "rescue", "eta_mins": 12},
    {"unit": "NDMA Team Alpha",     "type": "rescue", "eta_mins": 8},
    {"unit": "PDMA Response Unit",  "type": "rescue", "eta_mins": 15},
    {"unit": "1122 Rescue Service", "type": "rescue", "eta_mins": 10},
    {"unit": "Water Pump Unit 3",   "type": "pump",   "eta_mins": 14},
    {"unit": "Fire Tender Unit 2",  "type": "fire",   "eta_mins": 9},
]


def get_dispatch_unit(crisis_type: str, location: str) -> dict:
    """Pick relevant dispatch unit based on crisis type."""
    crisis_lower = crisis_type.lower()
    location_upper = location.upper()

    if "fire" in crisis_lower:
        unit = next((u for u in RESCUE_UNITS if u["type"] == "fire"), RESCUE_UNITS[0])
    elif "flood" in crisis_lower or "water" in crisis_lower:
        unit = next((u for u in RESCUE_UNITS if u["type"] == "pump"), RESCUE_UNITS[0])
    else:
        unit = random.choice([u for u in RESCUE_UNITS if u["type"] == "rescue"])

    # Vary ETA slightly based on location
    eta_variation = random.randint(-2, 4)
    unit = dict(unit)  # copy so we don't mutate original
    unit["eta_mins"] = max(5, unit["eta_mins"] + eta_variation)
    return unit


def get_alert_radius(severity: str) -> int:
    """Alert radius in km based on severity."""
    return {"HIGH": 3, "MEDIUM": 2, "LOW": 1}.get(severity, 2)


def get_affected_users(severity: str, location: str) -> int:
    """Estimate affected users based on severity and city density."""
    location_upper = location.upper()
    base = {"HIGH": 2000, "MEDIUM": 1000, "LOW": 500}.get(severity, 1000)

    if any(c in location_upper for c in ["KARACHI", "LAHORE"]):
        multiplier = random.uniform(1.5, 2.5)
    elif any(c in location_upper for c in ["ISLAMABAD", "RAWALPINDI", "FAISALABAD"]):
        multiplier = random.uniform(1.0, 1.8)
    else:
        multiplier = random.uniform(0.6, 1.2)

    return int(base * multiplier)


def plan(crisis_object: dict) -> dict:
    crisis_type = crisis_object.get("type", "Urban Flooding")
    location = crisis_object.get("location", "")
    severity = crisis_object.get("severity", "MEDIUM")

    dispatch_unit = get_dispatch_unit(crisis_type, location)
    alert_radius = get_alert_radius(severity)
    affected_users = get_affected_users(severity, location)

    crisis_object["_plan"] = {
        "dispatch_unit": dispatch_unit,
        "alert_radius_km": alert_radius,
        "estimated_affected_users": affected_users,
    }

    return crisis_object