# services/groq_service.py
# Calls Groq API with chain-of-thought reasoning prompt
# Called by reasoning_agent.py

import os
import json
from groq import Groq
from dotenv import load_dotenv

load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

REASONING_PROMPT = """
You are a crisis detection AI for urban areas in Pakistan.

Given the following signals:
- Citizen report: {citizen_text}
- Location: {location}
- Weather data: Rainfall {rainfall_mm}mm/hr, Alert: {weather_alert}
- Traffic data: Congestion spike {congestion_spike}%, Level: {congestion_level}
- Affected roads: {affected_roads}
- Detection notes: {detection_notes}

Perform chain-of-thought reasoning and output ONLY valid JSON.
No markdown, no backticks, no extra text — just the JSON object:

{{
  "type": "Urban Flooding",
  "location": "{location}",
  "severity": "HIGH or MEDIUM or LOW",
  "confidence": 0.0 to 1.0,
  "description": "one sentence summary of the crisis situation",
  "impacts": [
    {{"icon": "traffic", "text": "specific impact description"}},
    {{"icon": "car", "text": "specific impact description"}},
    {{"icon": "home", "text": "specific impact description"}}
  ],
  "recommendedActions": [
    "specific action 1 for this location",
    "specific action 2 for this location",
    "specific action 3 for this location"
  ],
  "explanation": "detailed chain-of-thought: what signals were received, how they were combined, why this severity was assigned, what the risk is if no action taken"
}}

Icon values must be one of: traffic, car, home, building, wind, water, alert
Make recommendedActions specific to the location and crisis type.
"""


def _fallback_response(crisis_candidate: dict) -> dict:
    """Used only if Groq API fails completely."""
    location = crisis_candidate["location"]
    severity = crisis_candidate["severity"]
    weather = crisis_candidate["weather"]
    traffic = crisis_candidate["traffic"]

    return {
        "type": "Urban Flooding",
        "location": location,
        "severity": severity,
        "confidence": 0.85,
        "description": f"Flash flood detected in {location} due to heavy rainfall of {weather['rainfall_mm']}mm/hr.",
        "impacts": [
            {"icon": "traffic", "text": f"Traffic blocked on {', '.join(traffic['affected_roads'][:2])}"},
            {"icon": "car", "text": "Vehicles stranded in floodwater"},
            {"icon": "home", "text": "Residential areas at risk of water damage"}
        ],
        "recommendedActions": [
            f"Dispatch emergency rescue units to {location}",
            f"Send SMS alert to residents within 2km of {location}",
            f"Reroute traffic away from {', '.join(traffic['affected_roads'][:1])}"
        ],
        "explanation": (
            f"Citizen report combined with {weather['rainfall_mm']}mm/hr rainfall "
            f"and {traffic['spike_percent']}% traffic spike in {location} "
            f"indicates {severity} probability urban flooding. "
            f"Immediate intervention recommended to prevent casualties."
        )
    }


def reason(crisis_candidate: dict) -> dict:
    signal = crisis_candidate["signal"]
    weather = crisis_candidate["weather"]
    traffic = crisis_candidate["traffic"]

    prompt = REASONING_PROMPT.format(
        citizen_text=signal["original_text"],
        location=crisis_candidate["location"],
        rainfall_mm=weather["rainfall_mm"],
        weather_alert=weather["alert"],
        congestion_spike=traffic["spike_percent"],
        congestion_level=traffic["congestion_level"],
        affected_roads=", ".join(traffic.get("affected_roads", [])),
        detection_notes=crisis_candidate["detection_notes"]
    )

    try:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3
        )
        raw_text = response.choices[0].message.content.strip()
        raw_text = raw_text.replace("```json", "").replace("```", "").strip()
        return json.loads(raw_text)
    except Exception as e:
        print(f"Groq API failed: {e} — using fallback")
        return _fallback_response(crisis_candidate)