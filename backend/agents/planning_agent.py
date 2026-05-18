# agents/planning_agent.py
# Layer 4 — Action Planning Agent
# Input:  crisis object from reasoning_agent
# Output: crisis object enriched with finalized actions + plan metadata
# Note:   Gemini already generates recommendedActions and impacts.
#         This agent validates, enriches, and adds routing/dispatch specifics.

DISPATCH_UNITS = [
    {"unit": "CDA Rescue Unit 4", "type": "rescue", "eta_mins": 12},
    {"unit": "NDMA Team Alpha",   "type": "rescue", "eta_mins": 8},
    {"unit": "Water Pump Unit 3", "type": "pump",   "eta_mins": 15},
    {"unit": "Fire Tender F-8",   "type": "fire",   "eta_mins": 10},
]

REROUTE_SUGGESTIONS = {
    "G-10": "Redirect via 9th Avenue → Khanna Pull",
    "G-9":  "Redirect via Srinagar Highway",
    "F-8":  "Redirect via Margalla Road",
    "DEFAULT": "Use alternate arterial roads — check Google Maps"
}


def get_dispatch_unit(crisis_type: str) -> dict:
    """Pick the most relevant dispatch unit based on crisis type."""
    if "flood" in crisis_type.lower():
        return next((u for u in DISPATCH_UNITS if u["type"] == "rescue"), DISPATCH_UNITS[0])
    if "fire" in crisis_type.lower():
        return next((u for u in DISPATCH_UNITS if u["type"] == "fire"), DISPATCH_UNITS[0])
    return DISPATCH_UNITS[0]


def get_reroute(location: str) -> str:
    for key, suggestion in REROUTE_SUGGESTIONS.items():
        if key in location.upper():
            return suggestion
    return REROUTE_SUGGESTIONS["DEFAULT"]


def plan(crisis_object: dict) -> dict:
    """
    Enriches the crisis object with dispatch unit and reroute plan.
    Returns the same crisis object with added plan metadata.
    """
    crisis_type = crisis_object.get("type", "")
    location = crisis_object.get("location", "")

    dispatch_unit = get_dispatch_unit(crisis_type)
    reroute = get_reroute(location)

    # Attach plan metadata used by simulation_agent
    crisis_object["_plan"] = {
        "dispatch_unit": dispatch_unit,
        "reroute_suggestion": reroute,
        "alert_radius_km": 2,
        "estimated_affected_users": 1240,
    }

    return crisis_object