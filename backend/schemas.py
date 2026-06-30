import re
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field, field_validator


# ---- Auth ----

class UserRegister(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

    @field_validator("name")
    @classmethod
    def name_not_blank(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("Name cannot be blank")
        return v

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one number")
        return v


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

class GoogleLoginPayload(BaseModel):
    id_token: str

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


# ---- Direct messages ----

class DirectMessageOut(BaseModel):
    id: str
    sender: str
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


class DirectMessageCreate(BaseModel):
    content: str = Field(min_length=1, max_length=4000)


class ConversationThreadOut(BaseModel):
    """One row in the Messages tab: a conversation plus its last message."""
    conversation_id: str
    provider_id: str
    provider_name: str
    last_message: str | None = None
    last_message_at: datetime | None = None

    class Config:
        from_attributes = True


class ConversationDetailOut(BaseModel):
    conversation_id: str
    provider_id: str
    provider_name: str
    messages: list[DirectMessageOut]


# ---- Bookings ----

class BookingCreate(BaseModel):
    provider_id: str
    notes: str | None = Field(default=None, max_length=500)


class BookingOut(BaseModel):
    id: str
    provider_id: str
    provider_name: str
    status: str
    scheduled_at: datetime | None = None
    notes: str | None = None
    created_at: datetime

    class Config:
        from_attributes = True