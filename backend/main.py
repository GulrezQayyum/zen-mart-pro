import firebase_admin
from firebase_admin import credentials, auth, db
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Initialize Firebase (replace with your credentials)
# Download your service account key from Firebase Console
# Project Settings -> Service Accounts -> Generate New Private Key
try:
    cred = credentials.Certificate("firebase-key.json")
    firebase_admin.initialize_app(cred, {
        'databaseURL': os.getenv('FIREBASE_DATABASE_URL', 'https://your-project.firebaseio.com')
    })
except Exception as e:
    print(f"Firebase initialization error: {e}")
    print("Make sure firebase-key.json is in the project root")

# Initialize FastAPI
app = FastAPI(title="Dashboard API", version="1.0.0")

# CORS Configuration
origins = [
    "http://localhost",
    "http://localhost:5000",
    "http://localhost:3000",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Import routes
from routes import auth_routes, admin_routes, vendor_routes

# Include routers
app.include_router(auth_routes.router, prefix="/api/auth", tags=["auth"])
app.include_router(admin_routes.router, prefix="/api/admin", tags=["admin"])
app.include_router(vendor_routes.router, prefix="/api/vendor", tags=["vendor"])

@app.get("/")
async def root():
    return {"message": "Dashboard API is running", "version": "1.0.0"}

@app.get("/health")
async def health():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)