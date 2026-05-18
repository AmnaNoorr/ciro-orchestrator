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
- Detection notes: {detection_notes}

Output ONLY valid JSON, no markdown, no backticks:
{{
  "type": "Urban Flooding",
  "location": "{location}",
  "severity": "HIGH or MEDIUM or LOW",
  "confidence": 0.0 to 1.0,
  "description": "one sentence summary",
  "impacts": [
    {{"icon": "traffic", "text": "impact description"}},
    {{"icon": "car", "text": "impact description"}},
    {{"icon": "home", "text": "impact description"}}
  ],
  "recommendedActions": [
    "action 1", "action 2", "action 3"
  ],
  "explanation": "chain-of-thought explanation"
}}
Icon values: traffic, car, home, building, wind, water, alert
"""


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
        detection_notes=crisis_candidate["detection_notes"]
    )

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3
    )

    raw_text = response.choices[0].message.content.strip()
    raw_text = raw_text.replace("```json", "").replace("```", "").strip()
    return json.loads(raw_text)