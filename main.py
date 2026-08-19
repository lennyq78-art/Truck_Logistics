from contextlib import asynccontextmanager
from datetime import datetime, timezone
import os
from typing import List

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session, joinedload

from database import engine, Base, get_db
import models
import schemas


# Automatic table creation on startup
@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title="Truck Trip Logging API",
    description="Backend service for tracking trucks, active trips, and automatic fare calculation in LKR",
    version="1.0.0",
    lifespan=lifespan,
)

# Enable CORS for Flutter app or any cross-origin client on the network
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static assets directory
if os.path.exists("static"):
    app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/", tags=["Dashboard"])
def root():
    """Serve Live Dashboard UI."""
    if os.path.exists("static/index.html"):
        return FileResponse("static/index.html")
    return {
        "status": "online",
        "service": "Truck Trip Logging API",
        "docs_url": "/docs",
    }


@app.get("/api/health", tags=["Health Check"])
def health_check():
    return {
        "status": "online",
        "service": "Truck Trip Logging API",
        "docs_url": "/docs",
    }


# ==========================================
# TRUCK ENDPOINTS
# ==========================================

@app.post("/trucks", response_model=schemas.TruckResponse, status_code=status.HTTP_201_CREATED, tags=["Trucks"])
def create_truck(truck_in: schemas.TruckCreate, db: Session = Depends(get_db)):
    """Create a new truck entry."""
    existing_truck = db.query(models.Truck).filter(
        models.Truck.plate_number == truck_in.plate_number
    ).first()
    if existing_truck:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Truck with plate number '{truck_in.plate_number}' already exists."
        )

    db_truck = models.Truck(
        plate_number=truck_in.plate_number,
        driver_name=truck_in.driver_name,
        rate_per_km=truck_in.rate_per_km,
    )
    db.add(db_truck)
    db.commit()
    db.refresh(db_truck)
    return db_truck


@app.get("/trucks", response_model=List[schemas.TruckResponse], tags=["Trucks"])
def list_trucks(db: Session = Depends(get_db)):
    """List all trucks."""
    return db.query(models.Truck).order_by(models.Truck.id.asc()).all()


# ==========================================
# TRIP ENDPOINTS
# ==========================================

# City GPS Coordinates mapping in Sri Lanka
CITY_COORDINATES = {
    "colombo": (6.9271, 79.8612),
    "kandy": (7.2906, 80.6337),
    "galle": (6.0535, 80.2210),
    "hambantota": (6.1246, 81.1185),
    "nuwara eliya": (6.9497, 80.7891),
    "dambulla": (7.8731, 80.6517),
    "jaffna": (9.6615, 80.0255),
    "trincomalee": (8.5874, 81.2152),
    "matara": (5.9549, 80.5550),
    "badulla": (6.9934, 81.0550),
}

def get_city_coords(location_name: str):
    loc_lower = location_name.lower()
    for city, coords in CITY_COORDINATES.items():
        if city in loc_lower:
            return coords
    # Default to Colombo if unknown city
    return (6.9271, 79.8612)


@app.post("/trips/start", response_model=schemas.TripResponse, status_code=status.HTTP_201_CREATED, tags=["Trips"])
def start_trip(trip_in: schemas.TripStartRequest, db: Session = Depends(get_db)):
    """Start a new trip for a truck (status='active')."""
    # 1. Verify truck exists
    truck = db.query(models.Truck).filter(models.Truck.id == trip_in.truck_id).first()
    if not truck:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Truck with ID {trip_in.truck_id} not found."
        )

    # 2. Check if truck already has an active trip
    active_trip = db.query(models.Trip).filter(
        models.Trip.truck_id == trip_in.truck_id,
        models.Trip.status == "active"
    ).first()
    if active_trip:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Truck {truck.plate_number} (ID {truck.id}) already has an active trip (Trip #{active_trip.id})."
        )

    # Lookup initial coordinates
    initial_lat, initial_lng = get_city_coords(trip_in.start_location)

    # 3. Create new active trip
    db_trip = models.Trip(
        truck_id=trip_in.truck_id,
        start_location=trip_in.start_location,
        end_location=trip_in.end_location,
        status="active",
        current_lat=initial_lat,
        current_lng=initial_lng,
        started_at=datetime.now(timezone.utc),
    )
    db.add(db_trip)
    db.commit()
    db.refresh(db_trip)
    return db_trip


@app.post("/trips/{trip_id}/location", response_model=schemas.TripResponse, tags=["Trips"])
def update_trip_location(trip_id: int, loc_in: schemas.GPSLocationUpdate, db: Session = Depends(get_db)):
    """Update live GPS location coordinates (latitude & longitude) for an active trip."""
    db_trip = db.query(models.Trip).options(joinedload(models.Trip.truck)).filter(models.Trip.id == trip_id).first()
    if not db_trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Trip with ID {trip_id} not found."
        )

    if db_trip.status != "active":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Trip #{trip_id} is not active."
        )

    db_trip.current_lat = loc_in.latitude
    db_trip.current_lng = loc_in.longitude

    db.commit()
    db.refresh(db_trip)
    return db_trip


@app.post("/trips/{trip_id}/end", response_model=schemas.TripResponse, tags=["Trips"])
def end_trip(trip_id: int, trip_end_in: schemas.TripEndRequest, db: Session = Depends(get_db)):
    """End an active trip, compute fare based on distance_km * truck.rate_per_km, and set status to 'completed'."""
    # 1. Fetch trip
    db_trip = db.query(models.Trip).options(joinedload(models.Trip.truck)).filter(models.Trip.id == trip_id).first()
    if not db_trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Trip with ID {trip_id} not found."
        )

    # 2. Check status
    if db_trip.status == "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Trip #{trip_id} is already completed."
        )

    # 3. Compute fare in LKR
    truck = db_trip.truck
    calculated_fare = round(trip_end_in.distance_km * truck.rate_per_km, 2)

    # 4. Update trip details
    db_trip.distance_km = trip_end_in.distance_km
    db_trip.fare = calculated_fare
    db_trip.status = "completed"
    db_trip.ended_at = datetime.now(timezone.utc)

    db.commit()
    db.refresh(db_trip)
    return db_trip


@app.get("/trips", response_model=List[schemas.TripResponse], tags=["Trips"])
def list_trips(db: Session = Depends(get_db)):
    """List all trips, sorted newest first."""
    return db.query(models.Trip).options(
        joinedload(models.Trip.truck)
    ).order_by(models.Trip.started_at.desc()).all()


@app.get("/trips/active", response_model=List[schemas.TripResponse], tags=["Trips"])
def list_active_trips(db: Session = Depends(get_db)):
    """List all currently active trips (for live dashboard), sorted newest first."""
    return db.query(models.Trip).options(
        joinedload(models.Trip.truck)
    ).filter(
        models.Trip.status == "active"
    ).order_by(models.Trip.started_at.desc()).all()
