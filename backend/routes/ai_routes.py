from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx

router = APIRouter(prefix="/api/cv", tags=["AI CV Generator"])

# Ollama local endpoint usually runs here
OLLAMA_URL = "http://localhost:11434/api/generate"
DEFAULT_MODEL = "mistral" 

class ImproveRequest(BaseModel):
    text: str
    section: str # summary, experience, skills

class ImproveResponse(BaseModel):
    improved_text: str

@router.post("/improve", response_model=ImproveResponse)
async def improve_text(req: ImproveRequest):
    prompt = f"Improve the following {req.section} for a professional CV in French or English (detect the language used). Make it sound professional, ATS-optimized, and impactful. Output ONLY the improved text, without introduction or quotes:\n\n{req.text}"
    
    payload = {
        "model": DEFAULT_MODEL,
        "prompt": prompt,
        "stream": False
    }
    
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(OLLAMA_URL, json=payload)
            response.raise_for_status()
            data = response.json()
            return ImproveResponse(improved_text=data.get("response", "").strip())
    except Exception as e:
        print(f"Error communicating with Ollama: {e}")
        raise HTTPException(status_code=503, detail="Local AI engine is not reachable. Ensure Ollama is running.")

class GenerateSummaryRequest(BaseModel):
    job_title: str
    key_skills: list[str]

@router.post("/summary")
async def generate_summary(req: GenerateSummaryRequest):
    skills_str = ", ".join(req.key_skills)
    prompt = f"Write a professional summary for a CV for a {req.job_title} highlighting the following skills: {skills_str}. Keep it under 4 sentences. Do not add any introduction or conclusion."
    
    payload = {
        "model": DEFAULT_MODEL,
        "prompt": prompt,
        "stream": False
    }
    
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(OLLAMA_URL, json=payload)
            response.raise_for_status()
            data = response.json()
            return {"summary": data.get("response", "").strip()}
    except Exception as e:
        raise HTTPException(status_code=503, detail="Error reaching Ollama")
