#!/bin/bash
cd "$(dirname "$0")"

if [ ! -d "venv" ]; then
    python3 -m venv venv
    source venv/bin/activate
    pip install fastapi uvicorn mcp pydantic
else
    source venv/bin/activate
fi

python3 main.py
