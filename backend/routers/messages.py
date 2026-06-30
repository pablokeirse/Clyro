from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import User, ServiceProvider, Conversation, DirectMessage
from schemas import (
    ConversationThreadOut,
    ConversationDetailOut,
    DirectMessageOut,
    DirectMessageCreate,
)
from auth_utils import require_token

router = APIRouter(prefix="/api/messages", tags=["messages"])


def _get_or_create_conversation(db: Session, user: User, provider_id: str) -> Conversation:
    provider = db.query(ServiceProvider).filter(ServiceProvider.id == provider_id).first()
    if not provider:
        raise HTTPException(status_code=404, detail="Provider not found")

    conversation = (
        db.query(Conversation)
        .filter(Conversation.user_id == user.id, Conversation.provider_id == provider_id)
        .first()
    )
    if not conversation:
        conversation = Conversation(user_id=user.id, provider_id=provider_id)
        db.add(conversation)
        db.commit()
        db.refresh(conversation)
    return conversation


@router.get("/threads", response_model=list[ConversationThreadOut])
def list_threads(user: User = Depends(require_token), db: Session = Depends(get_db)):
    """Returns the Messages tab: every conversation the user has started, newest first."""
    conversations = (
        db.query(Conversation)
        .filter(Conversation.user_id == user.id)
        .all()
    )

    threads: list[ConversationThreadOut] = []
    fallback_times: dict[str, object] = {}
    for c in conversations:
        last = c.messages[-1] if c.messages else None
        threads.append(
            ConversationThreadOut(
                conversation_id=c.id,
                provider_id=c.provider_id,
                provider_name=c.provider.name,
                last_message=last.content if last else None,
                last_message_at=last.created_at if last else None,
            )
        )
        fallback_times[c.id] = c.created_at

    threads.sort(key=lambda t: t.last_message_at or fallback_times[t.conversation_id], reverse=True)
    return threads


@router.get("/{provider_id}", response_model=ConversationDetailOut)
def get_conversation(
    provider_id: str,
    user: User = Depends(require_token),
    db: Session = Depends(get_db),
):
    """Fetches (and lazily creates) the conversation between the current user and a provider."""
    conversation = _get_or_create_conversation(db, user, provider_id)
    return ConversationDetailOut(
        conversation_id=conversation.id,
        provider_id=conversation.provider_id,
        provider_name=conversation.provider.name,
        messages=[DirectMessageOut.model_validate(m) for m in conversation.messages],
    )


@router.post("/{provider_id}", response_model=DirectMessageOut, status_code=201)
def send_message(
    provider_id: str,
    payload: DirectMessageCreate,
    user: User = Depends(require_token),
    db: Session = Depends(get_db),
):
    """Sends a message from the current user to a provider, creating the conversation if needed."""
    conversation = _get_or_create_conversation(db, user, provider_id)

    message = DirectMessage(conversation_id=conversation.id, sender="user", content=payload.content)
    db.add(message)
    db.commit()
    db.refresh(message)
    return message