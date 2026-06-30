import math

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from database import get_db
from models import ServiceProvider, User
from schemas import ProviderOut
from auth_utils import require_token

router = APIRouter(prefix="/api/services", tags=["services"])


def haversine_km(lat1, lon1, lat2, lon2) -> float:
    r = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    )
    return r * 2 * math.asin(math.sqrt(a))


@router.get("", response_model=list[ProviderOut])
def search_providers(
    category: str | None = Query(default=None, description="e.g. Plumber, Electrician, Cleaner"),
    radius_km: float = Query(default=5, ge=0.1, le=100),
    lat: float | None = Query(default=None),
    lng: float | None = Query(default=None),
    user: User = Depends(require_token),
    db: Session = Depends(get_db),
):
    q = db.query(ServiceProvider).filter(ServiceProvider.is_active == True)  # noqa: E712
    if category and category.lower() != "all":
        q = q.filter(ServiceProvider.category.ilike(f"%{category}%"))

    providers = q.all()
    results: list[ProviderOut] = []

    for p in providers:
        distance = None
        if lat is not None and lng is not None and p.latitude is not None and p.longitude is not None:
            distance = round(haversine_km(lat, lng, p.latitude, p.longitude), 1)
            if distance > radius_km:
                continue
        results.append(
            ProviderOut(id=p.id, name=p.name, category=p.category, info=p.info, distance_km=distance)
        )

    return results