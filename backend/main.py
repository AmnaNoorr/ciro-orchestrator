from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import ingest, crises, simulation, alerts, traces, websocket

app = FastAPI(title="CIRO Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ingest.router)
app.include_router(crises.router)
app.include_router(simulation.router)
app.include_router(alerts.router)
app.include_router(traces.router)
app.include_router(websocket.router)

@app.get("/health")
def health():
    return {"status": "CIRO backend running"}