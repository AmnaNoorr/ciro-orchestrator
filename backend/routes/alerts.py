# routes/alerts.py
from fastapi import APIRouter
import db

router = APIRouter()

@router.get("/alerts")
def get_all_alerts():
    return db.get_all_alerts()