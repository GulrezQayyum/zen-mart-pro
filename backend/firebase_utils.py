import firebase_admin
from firebase_admin import auth, firestore
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from models import UserRole
from datetime import datetime

security = HTTPBearer()

# Get Firestore client (assumes firebase_admin.initialize_app() already called)
db = firestore.client()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify Firebase token and return user info"""
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication credentials: {str(e)}"
        )

async def verify_admin(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify user is admin"""
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        user_role = decoded_token.get('role')
        
        if user_role != UserRole.ADMIN.value:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Admin access required"
            )
        return decoded_token
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication credentials: {str(e)}"
        )

async def verify_vendor(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify user is vendor"""
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        user_role = decoded_token.get('role')
        
        if user_role not in [UserRole.VENDOR.value, UserRole.ADMIN.value]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Vendor access required"
            )
        return decoded_token
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication credentials: {str(e)}"
        )

def create_user_in_firestore(uid: str, email: str, display_name: str, role: UserRole):
    """Create user record in Firestore (using Firestore, not Realtime DB)"""
    try:
        doc_ref = db.collection('users').document(uid)
        doc_ref.set({
            'uid': uid,
            'email': email,
            'displayName': display_name,
            'role': role.value,
            'createdAt': datetime.now().isoformat(),
            'photoURL': None,
            'status': 'active'
        })
        return True
    except Exception as e:
        print(f"Error creating user in database: {e}")
        return False

def set_custom_claims(uid: str, role: UserRole):
    """Set custom claims for role-based access control"""
    try:
        auth.set_custom_user_claims(uid, {'role': role.value})
        return True
    except Exception as e:
        print(f"Error setting custom claims: {e}")
        return False

def get_user_from_db(uid: str):
    """Retrieve user data from Firestore"""
    try:
        doc_ref = db.collection('users').document(uid)
        user = doc_ref.get()
        if user.exists:
            return user.to_dict()
        return None
    except Exception as e:
        print(f"Error retrieving user: {e}")
        return None

def delete_user_account(uid: str):
    """Delete user account from Firebase Auth and Firestore"""
    try:
        auth.delete_user(uid)
        db.collection('users').document(uid).delete()
        return True
    except Exception as e:
        print(f"Error deleting user: {e}")
        return False