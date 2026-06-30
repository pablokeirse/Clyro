import uuid
from datetime import datetime

from sqlalchemy import Column, String, DateTime, ForeignKey, Float, Text, Boolean
from sqlalchemy.orm import relationship

from database import Base


def gen_uuid() -> str:
    return str(uuid.uuid4())


class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=gen_uuid)
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    messages = relationship("ChatMessage", back_populates="user", cascade="all, delete-orphan")


class ServiceProvider(Base):
    __tablename__ = "service_providers"

    id = Column(String(36), primary_key=True, default=gen_uuid)
    name = Column(String(150), nullable=False)
    category = Column(String(100), nullable=False, index=True)
    info = Column(String(500), default="")
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    is_active = Column(Boolean, default=True)


class ChatMessage(Base):
    """Stores CLYROAI conversation turns per user so chat history can persist."""

    __tablename__ = "chat_messages"

    id = Column(String(36), primary_key=True, default=gen_uuid)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False, index=True)
    role = Column(String(20), nullable=False)  # "user" or "assistant"
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="messages")