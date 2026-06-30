from datetime import datetime
from pydantic import BaseModel, EmailStr, Field


# ---- Auth ----

class UserRegister(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: str
    name: str
    email: EmailStr

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


# ---- AI Chat ----

class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=4000)


class ChatMessageOut(BaseModel):
    id: str
    role: str
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


class ChatResponse(BaseModel):
    reply: ChatMessageOut


# ---- Service providers ----

class ProviderOut(BaseModel):
    id: str
    name: str
    category: str
    info: str
    distance_km: float | None = None

    class Config:
        from_attributes = True