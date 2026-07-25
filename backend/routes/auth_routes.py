from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
import firebase_admin
from firebase_admin import auth
from models import SignUpRequest, SignInRequest, AuthResponse, UserRole
from firebase_utils import (
    get_current_user, 
    create_user_in_firestore, 
    set_custom_claims,
    get_user_from_db
)
from datetime import datetime

router = APIRouter()
security = HTTPBearer()

@router.post("/signup", response_model=AuthResponse)
async def signup(request: SignUpRequest):
    try:
        user = auth.create_user(
            email=request.email,
            password=request.password,
            display_name=request.displayName,
        )
        set_custom_claims(user.uid, request.role)
        create_user_in_firestore(user.uid, request.email, request.displayName, request.role)
        custom_token = auth.create_custom_token(user.uid)
        return AuthResponse(
            uid=user.uid,
            email=user.email,
            displayName=request.displayName,
            role=request.role,
            token=custom_token.decode('utf-8') if isinstance(custom_token, bytes) else custom_token
        )
    except auth.EmailAlreadyExistsError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Invalid input: {str(e)}")
    except Exception as e:
        print(f"Signup error: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to create account")

@router.post("/signin", response_model=dict)
async def signin(request: SignInRequest):
    try:
        user = auth.get_user_by_email(request.email)
        user_data = get_user_from_db(user.uid)
        if not user_data:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        return {
            "message": "Sign in with Firebase SDK on client",
            "uid": user.uid,
            "email": user.email,
            "displayName": user.display_name,
            "role": user_data.get('role', 'user')
        }
    except auth.UserNotFoundError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Authentication failed")

@router.post("/verify-token")
async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        decoded_token = auth.verify_id_token(token)
        user_id = decoded_token.get('uid')
        user_data = get_user_from_db(user_id)
        return {
            "valid": True,
            "uid": user_id,
            "email": decoded_token.get('email'),
            "role": user_data.get('role') if user_data else 'user'
        }
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

@router.get("/me")
async def get_current_user_info(user = Depends(get_current_user)):
    try:
        user_data = get_user_from_db(user.get('uid'))
        return user_data
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to retrieve user info")

@router.post("/signout")
async def signout(user = Depends(get_current_user)):
    return {"message": "Successfully signed out"}