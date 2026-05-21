# Ciro Orchestrator

Ciro Orchestrator — Flood Crisis Simulation. This repository contains a crisis simulation platform focused on flood events. It includes a Python backend that runs agents for detection, reasoning and planning, a simulation engine for modeling flood scenarios, and a Flutter client for visualization and operator interaction. The system supports ingesting sensor and telemetry data, generating alerts and risk maps, running simulated scenarios, and coordinating response actions.

---

## Table of Contents

- Project Overview
- Features
- Repository Structure
- Getting Started
  - Prerequisites
  - Backend (Python) setup
  - Mobile (Flutter) setup
- Running with Docker
- API Endpoints (summary)
- Architecture & Screenshots
- Adding Images (where to put pictures)
- Development & Testing
- Contributing
- License
- Contact

---

## Project Overview

Ciro Orchestrator is a flood-focused crisis simulation platform. It pairs a Python backend (APIs, agents, and a simulation engine) with a Flutter front-end application (mobile and web) to support preparedness and response for flood events. Key capabilities include real-time ingestion of sensor and river-level data, probabilistic flood modeling, alert generation, evacuation and resource planning suggestions, multi-agent coordination for automated responses, and timeline-based simulation playback for drills and training.

## Features

- Real-time ingestion of environmental sensors and telemetry
- Flood modeling and risk-map generation
- Automated detection, reasoning, and evacuation planning agents
- Scenario simulation and timeline playback for training and testing
- Websocket streaming for live dashboards and alerts
- Cross-platform Flutter client for on-the-go situational awareness

## Repository Structure

- `backend/` — Python backend, agents, routes and services
- `lib/` — Flutter app source code
- `assets/` — App assets used by the Flutter client
- `mock/` — Sample/mock data used for simulation and testing
- `android/`, `ios/`, `linux/`, `macos/`, `windows/` — Platform-specific Flutter project files

See the folders for more details; key backend files: `backend/main.py`, `backend/Dockerfile`, `backend/requirements.txt`.

## Getting Started

### Prerequisites

- Python 3.10+ (or compatible) for backend
- pip (or pipenv/venv)
- Docker (optional)
- Flutter SDK for building/running the client

### Backend (Python) setup

1. Create and activate a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r backend/requirements.txt
```

3. Run the backend (development):

```bash
python backend/main.py
```

Environment variables: check `backend/` code for any expected env vars (database, GROQ credentials, etc.). Add them to a `.env` file or export before running.

### Mobile / Flutter setup

1. Ensure Flutter SDK is installed and on PATH.
2. From the repo root, run:

```bash
flutter pub get
flutter run
```

To run web:

```bash
flutter run -d chrome
```

## Running with Docker

Build and run the backend Docker image (if Dockerfile exists):

```bash
docker build -t ciro-backend -f backend/Dockerfile .
docker run -p 8000:8000 --env-file .env ciro-backend
```

Adjust ports and env-file as needed.

## API Endpoints (summary)

Routes are implemented in `backend/routes/` — quick overview:

- `/alerts` — alert ingest and retrieval
- `/crises` — crisis listing and details
- `/ingest` — ingest raw signals
- `/simulation` — run or control simulations
- `/traces` — trace logs and playback

Open the route files for exact request/response shapes.

## Architecture & Screenshots

This project includes UI screenshots architecture diagrams. Below are the current screenshots included in the repository — they are referenced with relative paths so they render on GitHub.

- **Ciro home page:**

  ![Ciro home page](Screenshot%202026-05-21%20065121.png)

- **Info about a crisis:**

  ![Info about crisis](Screenshot%202026-05-21%20065147.png)

- **Crisis simulation view:**

  ![Crisis simulation](Screenshot%202026-05-21%20065215.png)

## Development & Testing

- Backend tests: use `pytest` (if present). Run from repo root:

```bash
pytest -q
```

- Flutter tests:

```bash
flutter test
```

Code style: follow existing project conventions — prefer not to introduce auto-format changes in unrelated files.

## Contributing

Contributions are welcome. Typical flow:

1. Fork the repo
2. Create a feature branch
3. Add tests and update documentation
4. Open a pull request describing the changes

Be sure to run backend and Flutter tests locally before opening PRs.
