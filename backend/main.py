from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.exc import OperationalError

from config import settings
from database import Base, engine, SessionLocal
from models import ServiceProvider
from routers import auth, ai, services, users

try:
    Base.metadata.create_all(bind=engine)
except OperationalError as e:
    raise RuntimeError(
        "Could not connect to MySQL. Make sure MySQL is running, the database in "
        "DATABASE_URL exists (create it once in MySQL Workbench: "
        "CREATE DATABASE clyro;), and the credentials in .env are correct.\n"
        f"Original error: {e}"
    ) from e


def seed_providers():
    """Seeds a few demo providers on first run so the Search tab has data."""
    db = SessionLocal()
    try:
        if db.query(ServiceProvider).count() == 0:
            demo = [
                ServiceProvider(name="Plumber 1", category="Plumber", info="Leak repair, pipe installation", latitude=51.2095, longitude=3.2247),
                ServiceProvider(name="Plumber 2", category="Plumber", info="Emergency call-outs, 24/7", latitude=51.2105, longitude=3.2200),
                ServiceProvider(name="Plumber 3", category="Plumber", info="Bathroom & kitchen specialist", latitude=51.2050, longitude=3.2300),
                ServiceProvider(name="Electrician 1", category="Electrician", info="Wiring, rewiring, fuse boxes", latitude=51.2150, longitude=3.2280),
                ServiceProvider(name="Cleaner 1", category="Cleaner", info="Deep cleaning, move-out cleans", latitude=51.2080, longitude=3.2260),
            ]
            db.add_all(demo)
            db.commit()
    finally:
        db.close()


@asynccontextmanager
async def lifespan(app: FastAPI):
    seed_providers()
    yield


app = FastAPI(title="CLYRO API", version="1.0.0", lifespan=lifespan)

# We authenticate with a Bearer token header, not cookies, so allow_credentials
# can stay False — that's what lets allow_origins=["*"] work cleanly for any
# localhost port Flutter web happens to pick.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(ai.router)
app.include_router(services.router)
app.include_router(users.router)


@app.get("/")
def root():
    return {"status": "ok", "service": "CLYRO API"}


@app.get("/health")
def health():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)