# services/websocket_service.py
# Manages WebSocket connections and broadcasts crisis events to Flutter
# Called by pipeline_service.py after crisis is confirmed

import json
from typing import Set
from fastapi import WebSocket

# Active WebSocket connections set
active_connections: Set[WebSocket] = set()


async def connect(websocket: WebSocket):
    await websocket.accept()
    active_connections.add(websocket)


def disconnect(websocket: WebSocket):
    active_connections.discard(websocket)


async def broadcast_crisis(crisis_object: dict):
    """
    Pushes crisis_detected event to all connected Flutter clients.
    Flutter's dashboard_screen.dart listens for this.
    """
    message = json.dumps({
        "event": "crisis_detected",
        "data": crisis_object
    })

    dead = set()
    for connection in active_connections:
        try:
            await connection.send_text(message)
        except Exception:
            dead.add(connection)

    # Clean up dead connections
    for conn in dead:
        active_connections.discard(conn)