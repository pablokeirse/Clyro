from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import User, ChatMessage
from schemas import ChatRequest, ChatResponse, ChatMessageOut
from auth_utils import require_token
from gemini_client import generate_reply

router = APIRouter(prefix="/api/ai", tags=["ai"])

HISTORY_TURNS = 10  # how many prior messages to send back to Gemini as context


@router.post("/chat", response_model=ChatResponse)
def chat(
    payload: ChatRequest,
    user: User = Depends(require_token),
    db: Session = Depends(get_db),
):
    # Pull recent history for context, oldest first
    recent = (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == user.id)
        .order_by(ChatMessage.created_at.desc())
        .limit(HISTORY_TURNS)
        .all()
    )
    recent.reverse()
    history = [{"role": m.role, "content": m.content} for m in recent]

    # Save the user's message
    user_msg = ChatMessage(user_id=user.id, role="user", content=payload.message)
    db.add(user_msg)
    db.commit()

    try:
        reply_text = generate_reply(payload.message, history=history)
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))

    assistant_msg = ChatMessage(user_id=user.id, role="assistant", content=reply_text)
    db.add(assistant_msg)
    db.commit()
    db.refresh(assistant_msg)

    return ChatResponse(reply=ChatMessageOut.model_validate(assistant_msg))


@router.get("/chat/history", response_model=list[ChatMessageOut])
def chat_history(
    user: User = Depends(require_token),
    db: Session = Depends(get_db),
):
    messages = (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == user.id)
        .order_by(ChatMessage.created_at.asc())
        .all()
    )
    return messages