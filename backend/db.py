# db.py — Simple in-memory store
# All agents write here, all routes read from here

from typing import Dict, Any

_store: Dict[str, Any] = {
    "crises": {},        # crisis_id -> crisis object
    "simulations": {},   # crisis_id -> simulation object
    "alerts": {},        # crisis_id -> alert object
    "traces": {},        # crisis_id -> trace logs list
}

def save_crisis(crisis_id: str, data: dict):
    _store["crises"][crisis_id] = data

def get_all_crises() -> list:
    return list(_store["crises"].values())

def get_crisis(crisis_id: str) -> dict:
    return _store["crises"].get(crisis_id)

def save_simulation(crisis_id: str, data: dict):
    _store["simulations"][crisis_id] = data

def get_simulation(crisis_id: str) -> dict:
    return _store["simulations"].get(crisis_id)

def save_alert(crisis_id: str, data: dict):
    _store["alerts"][crisis_id] = data

def get_all_alerts() -> list:
    return list(_store["alerts"].values())

def save_trace(crisis_id: str, logs: list):
    _store["traces"][crisis_id] = logs

def get_trace(crisis_id: str) -> list:
    return _store["traces"].get(crisis_id, [])