import os
import random
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv()

app = FastAPI()

# Retrieve API keys and split them into a list
HF_API_KEYS = os.getenv("HF_API_KEYS", "").split(",")
MODEL_ID = "google/gemma-3-27b-it"
HF_API_URL = f"https://api-inference.huggingface.co/models/{MODEL_ID}"

class InputData(BaseModel):
    inputs: str
    parameters: dict = None

@app.post("/evaluate")
async def evaluate(data: InputData):
    try:
        payload = data.model_dump()
        
        # Randomly select an API key
        api_key = random.choice(HF_API_KEYS).strip()
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }

        response = requests.post(HF_API_URL, headers=headers, json=payload)
        response.raise_for_status()
        return response.json()
    
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
