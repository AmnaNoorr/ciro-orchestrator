# routes/ingest.py
from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from services.pipeline_service import run_pipeline

router = APIRouter()

class SignalInput(BaseModel):
    text: str
    language: Optional[str] = "en"
    location: Optional[str] = "Unknown"
    photo_url: Optional[str] = None

@router.post("/ingest")
async def ingest_signal(signal: SignalInput):
    result = await run_pipeline(signal.dict())
    return result