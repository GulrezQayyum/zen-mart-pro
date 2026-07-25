from fastapi import APIRouter, HTTPException, status
from firebase_admin import db
from models import VendorDashboardData, DashboardStats
from firebase_utils import verify_vendor, get_user_from_db

router = APIRouter()

@router.get("/dashboard")
async def get_vendor_dashboard(user = None):
    """
    Get vendor dashboard data
    Only accessible by vendor and admin roles
    """
    try:
        # Get vendor's own data
        user_id = user.get('uid') if user else None
        
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not authenticated"
            )
        
        user_data = get_user_from_db(user_id)
        
        if not user_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        stats = DashboardStats(
            totalUsers=1,  # Vendor's own data
            totalVendors=0,
            activeSession=True
        )
        
        return VendorDashboardData(
            vendorName=user_data.get('displayName', 'Vendor'),
            stats=stats,
            recentActivity=[]
        )
    
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error fetching vendor dashboard: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch dashboard data"
        )

@router.get("/profile")
async def get_vendor_profile(user = None):
    """
    Get vendor profile information
    """
    try:
        user_id = user.get('uid') if user else None
        
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not authenticated"
            )
        
        user_data = get_user_from_db(user_id)
        
        if not user_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        return {
            "uid": user_id,
            "displayName": user_data.get('displayName'),
            "email": user_data.get('email'),
            "role": user_data.get('role'),
            "createdAt": user_data.get('createdAt'),
            "photoURL": user_data.get('photoURL'),
            "status": user_data.get('status', 'active')
        }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch profile"
        )

@router.put("/profile")
async def update_vendor_profile(displayName: str = None, photoURL: str = None, user = None):
    """
    Update vendor profile information
    """
    try:
        user_id = user.get('uid') if user else None
        
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not authenticated"
            )
        
        update_data = {}
        if displayName:
            update_data['displayName'] = displayName
        if photoURL:
            update_data['photoURL'] = photoURL
        
        ref = db.reference(f'users/{user_id}')
        ref.update(update_data)
        
        return {
            "message": "Profile updated successfully",
            "updated_fields": update_data
        }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update profile"
        )

@router.get("/stats")
async def get_vendor_stats(user = None):
    """
    Get vendor-specific statistics
    """
    try:
        user_id = user.get('uid') if user else None
        
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not authenticated"
            )
        
        return {
            "vendorId": user_id,
            "activeListings": 0,
            "totalSales": 0,
            "rating": 0.0,
            "joinDate": None
        }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch statistics"
        )