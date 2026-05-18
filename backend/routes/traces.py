# routes/traces.py
from fastapi import APIRouter, HTTPException
import db

router = APIRouter()

@router.get("/traces/{crisis_id}")
def get_trace(crisis_id: str):
    trace = db.get_trace(crisis_id)
    if not trace:
        raise HTTPException(status_code=404, detail="Trace not found")
    return {"crisisId": crisis_id, "logs": trace}