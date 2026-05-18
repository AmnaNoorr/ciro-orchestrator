# services/pipeline_service.py
# Orchestrates all 5 agents in sequence
# Called by routes/ingest.py
# Writes all results to db.py
# Pushes WebSocket event after completion

import db
from agents.signal_agent import normalize
from agents.detection_agent import detect
from agents.reasoning_agent import analyze
from agents.planning_agent import plan
from agents.simulation_agent import simulate
from services.websocket_service import broadcast_crisis


async def run_pipeline(raw_input: dict) -> dict:
    """
    Full agent pipeline:
    signal → detect → reason → plan → simulate → store → broadcast
    """

    # --- Agent 1: Signal Normalization ---
    normalized = normalize(raw_input)

    # --- Agent 2: Event Detection ---
    crisis_candidate = detect(normalized)

    if not crisis_candidate["is_crisis"]:
        return {
            "status": "no_crisis",
            "message": "Signal did not meet crisis threshold",
            "crisis_id": None
        }

    # --- Agent 3: LLM Reasoning (Gemini) ---
    crisis_object = analyze(crisis_candidate)

    # Attach raw text for trace logs
    crisis_object["_raw_text"] = raw_input.get("text", "")

    # --- Agent 4: Action Planning ---
    crisis_object = plan(crisis_object)

    # --- Agent 5: Simulation & Execution ---
    simulation_result, alert_result, trace_logs = simulate(crisis_object)

    # --- Store everything in db ---
    crisis_id = crisis_object["id"]

    # Remove internal plan metadata before storing (not needed by Flutter)
    crisis_object.pop("_plan", None)
    crisis_object.pop("_raw_text", None)

    db.save_crisis(crisis_id, crisis_object)
    db.save_simulation(crisis_id, simulation_result)
    db.save_alert(crisis_id, alert_result)
    db.save_trace(crisis_id, trace_logs)

    # --- Broadcast to Flutter via WebSocket ---
    await broadcast_crisis(crisis_object)

    return {
        "status": "crisis_detected",
        "crisis_id": crisis_id,
        "severity": crisis_object["severity"],
        "message": f"Crisis detected at {crisis_object['location']}"
    }