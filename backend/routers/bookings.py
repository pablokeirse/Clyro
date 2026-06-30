from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import User, ServiceProvider, Booking
from schemas import BookingCreate, BookingOut
from auth_utils import require_token

router = APIRouter(prefix="/api/bookings", tags=["bookings"])


@router.get("", response_model=list[BookingOut])
def list_my_bookings(user: User = Depends(require_token), db: Session = Depends(get_db)):
    """Returns the current user's service requests, newest first, for the My services tab."""
    bookings = (
        db.query(Booking)
        .filter(Booking.user_id == user.id)
        .order_by(Booking.created_at.desc())
        .all()
    )
    return [
        BookingOut(
            id=b.id,
            provider_id=b.provider_id,
            provider_name=b.provider.name,
            status=b.status,
            scheduled_at=b.scheduled_at,
            notes=b.notes,
            created_at=b.created_at,
        )
        for b in bookings
    ]


@router.post("", response_model=BookingOut, status_code=201)
def create_booking(
    payload: BookingCreate,
    user: User = Depends(require_token),
    db: Session = Depends(get_db),
):
    """Creates a new service request ('Book now') for a provider."""
    provider = db.query(ServiceProvider).filter(ServiceProvider.id == payload.provider_id).first()
    if not provider:
        raise HTTPException(status_code=404, detail="Provider not found")

    booking = Booking(
        user_id=user.id,
        provider_id=provider.id,
        status=Booking.STATUS_REQUESTED,
        notes=payload.notes,
    )
    db.add(booking)
    db.commit()
    db.refresh(booking)

    return BookingOut(
        id=booking.id,
        provider_id=booking.provider_id,
        provider_name=provider.name,
        status=booking.status,
        scheduled_at=booking.scheduled_at,
        notes=booking.notes,
        created_at=booking.created_at,
    )