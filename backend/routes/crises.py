# routes/crises.py
from fastapi import APIRouter, HTTPException
import db

router = APIRouter()

@router.get("/crises")
def get_all_crises():
    return db.get_all_crises()

@router.get("/crises/{crisis_id}")
def get_crisis(crisis_id: str):
    crisis = db.get_crisis(crisis_id)
    if not crisis:
        raise HTTPException(status_code=404, detail="Crisis not found")
    return crisis