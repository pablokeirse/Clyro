from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from models import User
from schemas import UserOut, UserUpdate
from auth_utils import require_token

router = APIRouter(prefix="/api/users", tags=["users"])


@router.get("/me", response_model=UserOut)
def get_me(user: User = Depends(require_token)):
    return user


@router.put("/me", response_model=UserOut)
def update_me(
    payload: UserUpdate,
    user: User = Depends(require_token),
    db: Session = Depends(get_db),
):
    if payload.name is not None and payload.name.strip():
        user.name = payload.name.strip()
    db.commit()
    db.refresh(user)
    return user