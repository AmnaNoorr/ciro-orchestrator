# routes/simulation.py
from fastapi import APIRouter, HTTPException
import db

router = APIRouter()

@router.get("/simulation/{crisis_id}")
def get_simulation(crisis_id: str):
    sim = db.get_simulation(crisis_id)
    if not sim:
        raise HTTPException(status_code=404, detail="Simulation not found")
    return sim