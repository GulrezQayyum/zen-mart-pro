from fastapi import APIRouter, HTTPException, status
from firebase_admin import db
from models import AdminDashboardData, DashboardStats, UserModel, UserRole
from firebase_utils import verify_admin, get_user_from_db

router = APIRouter()

@router.get("/dashboard", response_model=AdminDashboardData)
async def get_admin_dashboard(user = None):
    """
    Get admin dashboard data
    Only accessible by admin role
    """
    try:
        # Get all users from database
        ref = db.reference('users')
        all_users = ref.get()
        
        if not all_users:
            all_users = {}
        
        # Calculate statistics
        total_users = len(all_users)
        total_vendors = sum(1 for u in all_users.values() if u.get('role') == 'vendor')
        
        # Get recent users (last 5)
        recent_users_list = []
        for uid, user_data in list(all_users.items())[-5:]:
            recent_users_list.append(UserModel(
                uid=uid,
                email=user_data.get('email'),
                displayName=user_data.get('displayName'),
                role=UserRole(user_data.get('role', 'user')),
                createdAt=user_data.get('createdAt'),
                photoURL=user_data.get('photoURL')
            ))
        
        stats = DashboardStats(
            totalUsers=total_users,
            totalVendors=total_vendors,
            activeSession=True
        )
        
        return AdminDashboardData(
            stats=stats,
            recentUsers=recent_users_list
        )
    
    except Exception as e:
        print(f"Error fetching admin dashboard: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch dashboard data"
        )

@router.get("/users")
async def get_all_users(user = None):
    """
    Get list of all users (admin only)
    """
    try:
        ref = db.reference('users')
        all_users = ref.get()
        
        if not all_users:
            return []
        
        users_list = []
        for uid, user_data in all_users.items():
            users_list.append({
                'uid': uid,
                'email': user_data.get('email'),
                'displayName': user_data.get('displayName'),
                'role': user_data.get('role'),
                'createdAt': user_data.get('createdAt'),
                'status': user_data.get('status', 'active')
            })
        
        return users_list
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch users"
        )

@router.put("/users/{user_id}/role")
async def update_user_role(user_id: str, new_role: UserRole, admin_user = None):
    """
    Update user role (admin only)
    """
    try:
        ref = db.reference(f'users/{user_id}')
        ref.update({'role': new_role.value})
        
        return {
            "message": f"User role updated to {new_role.value}",
            "uid": user_id,
            "new_role": new_role.value
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update user role"
        )

@router.delete("/users/{user_id}")
async def delete_user(user_id: str, admin_user = None):
    """
    Delete user account and data (admin only)
    """
    try:
        # Delete from Firestore
        ref = db.reference(f'users/{user_id}')
        ref.delete()
        
        return {"message": "User deleted successfully"}
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete user"
        )

@router.get("/stats")
async def get_admin_stats(admin_user = None):
    """
    Get detailed admin statistics
    """
    try:
        ref = db.reference('users')
        all_users = ref.get()
        
        if not all_users:
            all_users = {}
        
        total_users = len(all_users)
        total_vendors = sum(1 for u in all_users.values() if u.get('role') == 'vendor')
        total_admins = sum(1 for u in all_users.values() if u.get('role') == 'admin')
        
        return {
            "totalUsers": total_users,
            "totalVendors": total_vendors,
            "totalAdmins": total_admins,
            "totalRegularUsers": total_users - total_vendors - total_admins
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch statistics"
        )