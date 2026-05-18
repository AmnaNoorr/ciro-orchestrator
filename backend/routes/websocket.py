# routes/websocket.py
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from services.websocket_service import connect, disconnect

router = APIRouter()

@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await connect(websocket)
    try:
        while True:
            # Keep connection alive — just receive pings
            await websocket.receive_text()
    except WebSocketDisconnect:
        disconnect(websocket)