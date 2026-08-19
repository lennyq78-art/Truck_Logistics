from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


# --- Truck Schemas ---
class TruckBase(BaseModel):
    plate_number: str = Field(..., description="Truck license plate number or name", examples=["WP CAD-1234"])
    driver_name: str = Field(..., description="Driver full name", examples=["Kamal Perera"])
    rate_per_km: float = Field(..., gt=0, description="Rate per kilometer in LKR", examples=[150.0])


class TruckCreate(TruckBase):
    pass


class TruckResponse(TruckBase):
    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# --- Trip Schemas ---
class TripStartRequest(BaseModel):
    truck_id: int = Field(..., description="ID of the truck starting the trip", examples=[1])
    start_location: str = Field(..., description="Starting city/location", examples=["Colombo"])
    end_location: str = Field(..., description="Destination city/location", examples=["Kandy"])


class TripEndRequest(BaseModel):
    distance_km: float = Field(..., gt=0, description="Actual distance traveled in kilometers", examples=[115.5])


class GPSLocationUpdate(BaseModel):
    latitude: float = Field(..., description="GPS Latitude coordinate", examples=[6.9271])
    longitude: float = Field(..., description="GPS Longitude coordinate", examples=[79.8612])


class TripResponse(BaseModel):
    id: int
    truck_id: int
    start_location: str
    end_location: str
    distance_km: Optional[float] = None
    fare: Optional[float] = None
    current_lat: Optional[float] = None
    current_lng: Optional[float] = None
    status: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    truck: Optional[TruckResponse] = None

    model_config = ConfigDict(from_attributes=True)
