# agents/simulation_agent.py
# Layer 5 — Simulation & Execution Agent (CRITICAL)
# Input:  crisis object with _plan from planning_agent
# Output: simulation dict, alert dict, trace logs
#         All match simulation.json, alerts.json, traces.json schemas exactly

import uuid
import random
from datetime import datetime, timezone


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _ticket_id() -> str:
    return "TKT-" + str(random.randint(1000, 9999))


def _generate_blocked_routes(coords: dict) -> list:
    """Generate blocked route coordinates around the crisis point."""
    if not coords or coords.get("lat") is None:
        return []

    lat, lng = coords["lat"], coords["lng"]
    return [
        [
            {"lat": lat,         "lng": lng},
            {"lat": lat - 0.002, "lng": lng + 0.004}
        ],
        [
            {"lat": lat - 0.002, "lng": lng + 0.004},
            {"lat": lat - 0.005, "lng": lng + 0.001}
        ]
    ]


def _generate_rerouted_paths(coords: dict) -> list:
    """Generate alternate route coordinates bypassing the crisis point."""
    if not coords or coords.get("lat") is None:
        return []

    lat, lng = coords["lat"], coords["lng"]
    return [
        [
            {"lat": lat,         "lng": lng},
            {"lat": lat + 0.003, "lng": lng - 0.001}
        ],
        [
            {"lat": lat + 0.003, "lng": lng - 0.001},
            {"lat": lat + 0.005, "lng": lng + 0.007}
        ],
        [
            {"lat": lat + 0.005, "lng": lng + 0.007},
            {"lat": lat - 0.002, "lng": lng + 0.004}
        ]
    ]


def simulate(crisis_object: dict) -> tuple:
    crisis_id = crisis_object["id"]
    location = crisis_object["location"]
    coords = crisis_object.get("coordinates", {"lat": None, "lng": None})
    plan = crisis_object.get("_plan", {})
    severity = crisis_object.get("severity", "MEDIUM")

    dispatch = plan.get("dispatch_unit", {"unit": "NDMA Rescue Unit", "eta_mins": 10})
    affected_users = plan.get("estimated_affected_users", 1200)
    alert_radius = plan.get("alert_radius_km", 2)

    blocked_routes = _generate_blocked_routes(coords)
    rerouted_paths = _generate_rerouted_paths(coords)

    # Congestion reduction varies by severity
    congestion_reduced = {"HIGH": random.randint(40, 60),
                          "MEDIUM": random.randint(25, 45),
                          "LOW": random.randint(15, 30)}.get(severity, 35)

    ticket = {
        "id": _ticket_id(),
        "unit": dispatch["unit"],
        "eta": f"{dispatch['eta_mins']} mins",
        "status": "DISPATCHED"
    }

    alert_message = (
        f"Alert sent to {affected_users:,} users within {alert_radius}km of "
        f"{location} regarding {crisis_object['type']}."
    )

    # Simulation result — matches simulation.json schema
    simulation_result = {
        crisis_id: {
            "kpis": {
                "congestionReduced": congestion_reduced,
                "routesCleared": len(rerouted_paths),
                "alertsSent": affected_users,
                "unitsDispatched": 2
            },
            "blockedRoutes": blocked_routes,
            "reroutedPaths": rerouted_paths,
            "ticket": ticket,
            "alertMessage": alert_message
        }
    }

    # Alert object — matches alerts.json schema
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

    # Trace logs — matches traces.json schema
    trace_logs = [
        {
            "agent": "SignalAgent",
            "action": "Ingested Report",
            "timestamp": _now(),
            "reasoning": (
                f"Received input: '{crisis_object.get('_raw_text', 'citizen report')}'. "
                f"Parsed language and extracted flood-related keywords."
            ),
            "color": "#00E5FF"
        },
        {
            "agent": "DetectionAgent",
            "action": "Correlated Data",
            "timestamp": _now(),
            "reasoning": (
                f"Cross-referenced {location} with simulated weather and traffic data. "
                f"Confidence set to {int(crisis_object.get('confidence', 0.9) * 100)}%."
            ),
            "color": "#FFC400"
        },
        {
            "agent": "PlannerAgent",
            "action": "Generated Response Plan",
            "timestamp": _now(),
            "reasoning": (
                f"Alert radius: {alert_radius}km. "
                f"Dispatching {dispatch['unit']}. "
                f"Alerting {affected_users:,} users."
            ),
            "color": "#FF3D00"
        },
        {
            "agent": "SimulationAgent",
            "action": "Simulated Execution",
            "timestamp": _now(),
            "reasoning": (
                f"Blocked {len(blocked_routes)} routes near {location}. "
                f"Generated {len(rerouted_paths)} alternate paths. "
                f"Ticket {ticket['id']} created. ETA: {ticket['eta']}. "
                f"Congestion reduced by {congestion_reduced}%."
            ),
            "color": "#00E676"
        }
    ]

    full_trace = {
        "crisisId": crisis_id,
        "logs": trace_logs
    }

    return simulation_result, alert_result, full_trace