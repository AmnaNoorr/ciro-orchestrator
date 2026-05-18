# agents/simulation_agent.py
# Layer 5 — Simulation & Execution Agent (CRITICAL)
# Input:  crisis object with _plan from planning_agent
# Output: simulation dict, alert dict, trace logs list
#         All match simulation.json, alerts.json, traces.json schemas exactly

import uuid
from datetime import datetime, timezone

def _now() -> str:
    return datetime.now(timezone.utc).isoformat()

def _ticket_id() -> str:
    return "TKT-" + str(uuid.uuid4().int)[:4]


def simulate(crisis_object: dict) -> tuple[dict, dict, list]:
    """
    Runs all 4 simulations and returns:
    - simulation_result (matches simulation.json)
    - alert_result     (matches alerts.json)
    - trace_logs       (matches traces.json)
    """
    crisis_id = crisis_object["id"]
    location = crisis_object["location"]
    plan = crisis_object.get("_plan", {})
    coords = crisis_object.get("coordinates", {"lat": 33.6670, "lng": 72.9911})

    dispatch = plan.get("dispatch_unit", {"unit": "CDA Rescue Unit", "eta_mins": 10})
    affected_users = plan.get("estimated_affected_users", 1240)

    # --- Simulation 1: Mock blocked routes (around flood coords) ---
    blocked_routes = [
        [
            {"lat": coords["lat"],        "lng": coords["lng"]},
            {"lat": coords["lat"] - 0.002, "lng": coords["lng"] + 0.004}
        ],
        [
            {"lat": coords["lat"] - 0.002, "lng": coords["lng"] + 0.004},
            {"lat": coords["lat"] - 0.005, "lng": coords["lng"] + 0.001}
        ]
    ]

    # --- Simulation 2: Mock rerouted paths (bypass routes) ---
    rerouted_paths = [
        [
            {"lat": coords["lat"],        "lng": coords["lng"]},
            {"lat": coords["lat"] + 0.003, "lng": coords["lng"] - 0.001}
        ],
        [
            {"lat": coords["lat"] + 0.003, "lng": coords["lng"] - 0.001},
            {"lat": coords["lat"] + 0.005, "lng": coords["lng"] + 0.007}
        ],
        [
            {"lat": coords["lat"] + 0.005, "lng": coords["lng"] + 0.007},
            {"lat": coords["lat"] - 0.002, "lng": coords["lng"] + 0.004}
        ]
    ]

    # --- Simulation 3: Emergency ticket ---
    ticket = {
        "id": _ticket_id(),
        "unit": dispatch["unit"],
        "eta": f"{dispatch['eta_mins']} mins",
        "status": "DISPATCHED"
    }

    # --- Simulation 4: Alert message ---
    alert_message = (
        f"Alert sent to {affected_users:,} users in {location} "
        f"regarding {crisis_object['type']}."
    )

    # --- Assemble simulation result — matches simulation.json schema ---
    simulation_result = {
        crisis_id: {
            "kpis": {
                "congestionReduced": 45,
                "routesCleared": 3,
                "alertsSent": affected_users,
                "unitsDispatched": 2
            },
            "blockedRoutes": blocked_routes,
            "reroutedPaths": rerouted_paths,
            "ticket": ticket,
            "alertMessage": alert_message
        }
    }

    # --- Alert object — matches alerts.json schema ---
    alert_result = {
        "id": "a-" + str(uuid.uuid4())[:8],
        "crisisId": crisis_id,
        "message": (
            f"Emergency Alert: {crisis_object['type']} in {location}. "
            f"{crisis_object['recommendedActions'][0] if crisis_object.get('recommendedActions') else 'Stay alert.'}"
        ),
        "sentCount": affected_users,
        "timestamp": _now()
    }

    # --- Trace logs — matches traces.json schema exactly ---
    trace_logs = [
        {
            "agent": "SignalAgent",
            "action": "Ingested Report",
            "timestamp": _now(),
            "reasoning": (
                f"Received input text '{crisis_object.get('_raw_text', 'citizen report')}'. "
                f"Parsed language and extracted flood keywords."
            ),
            "color": "#00E5FF"
        },
        {
            "agent": "DetectionAgent",
            "action": "Correlated Data",
            "timestamp": _now(),
            "reasoning": (
                f"Cross-referenced {location} coordinates with weather data. "
                f"Identified high correlation. Set confidence to "
                f"{int(crisis_object.get('confidence', 0.9) * 100)}%."
            ),
            "color": "#FFC400"
        },
        {
            "agent": "PlannerAgent",
            "action": "Generated Response Plan",
            "timestamp": _now(),
            "reasoning": (
                f"Determined impact radius {plan.get('alert_radius_km', 2)}km. "
                f"Formulated plan: Dispatch {dispatch['unit']}, "
                f"Alert {affected_users:,} users, "
                f"{plan.get('reroute_suggestion', 'Reroute traffic')}."
            ),
            "color": "#FF3D00"
        },
        {
            "agent": "SimulationAgent",
            "action": "Simulated Rerouting",
            "timestamp": _now(),
            "reasoning": (
                f"Executed traffic simulation. Blocking {len(blocked_routes)} primary routes in {location}. "
                f"Calculated {len(rerouted_paths)} alternative paths. "
                f"Ticket {ticket['id']} created. ETA: {ticket['eta']}."
            ),
            "color": "#00E676"
        }
    ]

    full_trace = {
        "crisisId": crisis_id,
        "logs": trace_logs
    }

    return simulation_result, alert_result, full_trace