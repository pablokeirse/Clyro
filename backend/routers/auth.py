from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from database import get_db
from models import User
from schemas import UserRegister, UserLogin, TokenOut, ForgotPasswordRequest
from auth_utils import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=TokenOut, status_code=status.HTTP_201_CREATED)
def register(payload: UserRegister, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="An account with this email already exists")

    user = User(
        name=payload.name,
        email=payload.email,
        hashed_password=hash_password(payload.password),
    )
    db.add(user)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="An account with this email already exists")
    db.refresh(user)

    token = create_access_token(user.id)
    return TokenOut(access_token=token, user=user)


@router.post("/login", response_model=TokenOut)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    token = create_access_token(user.id)
    return TokenOut(access_token=token, user=user)


@router.post("/forgot-password", status_code=status.HTTP_202_ACCEPTED)
def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    """
    Always responds the same way regardless of whether the email exists,
    so the endpoint can't be used to enumerate registered accounts.

    NOTE: this is a stub - it doesn't actually send an email yet. Wire up
    a transactional email provider (e.g. Resend, SendGrid, SES) here and
    generate a short-lived reset token instead of just logging.
    """
    user = db.query(User).filter(User.email == payload.email).first()
    if user:
        print(f"[forgot-password] would send a reset email to {user.email}")
    return {"detail": "If that email is registered, a reset link has been sent."}