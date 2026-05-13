from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import models
from database import engine
from routes import ai_routes

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="SmartCV AI Local API")

# Setup CORS for Flutter app communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ai_routes.router)

@app.get("/")
def read_root():
    return {"message": "SmartCV AI Backend running locally!"}
