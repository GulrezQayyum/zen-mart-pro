from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from enum import Enum

class UserRole(str, Enum):
    ADMIN = "admin"
    VENDOR = "vendor"
    USER = "user"

class SignUpRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    displayName: str = Field(..., min_length=2)
    role: UserRole = UserRole.USER

class SignInRequest(BaseModel):
    email: EmailStr
    password: str

class UserModel(BaseModel):
    uid: str
    email: str
    displayName: str
    role: UserRole
    createdAt: str
    photoURL: Optional[str] = None
    
    class Config:
        from_attributes = True

class AuthResponse(BaseModel):
    uid: str
    email: str
    displayName: str
    role: UserRole
    token: str

class UpdateProfileRequest(BaseModel):
    displayName: Optional[str] = None
    photoURL: Optional[str] = None

class DashboardStats(BaseModel):
    totalUsers: int = 0
    totalVendors: int = 0
    activeSession: bool = True

class AdminDashboardData(BaseModel):
    stats: DashboardStats
    recentUsers: list[UserModel] = []

class VendorDashboardData(BaseModel):
    vendorName: str
    stats: DashboardStats
    recentActivity: list = []