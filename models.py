from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


def utc_now():
    return datetime.now(timezone.utc)


class Truck(Base):
    __tablename__ = "trucks"

    id = Column(Integer, primary_key=True, index=True)
    plate_number = Column(String, unique=True, index=True, nullable=False)
    driver_name = Column(String, nullable=False)
    rate_per_km = Column(Float, nullable=False)  # in LKR
    created_at = Column(DateTime(timezone=True), default=utc_now)

    trips = relationship("Trip", back_populates="truck", cascade="all, delete-orphan")


class Trip(Base):
    __tablename__ = "trips"

    id = Column(Integer, primary_key=True, index=True)
    truck_id = Column(Integer, ForeignKey("trucks.id"), nullable=False, index=True)
    start_location = Column(String, nullable=False)
    end_location = Column(String, nullable=False)
    distance_km = Column(Float, nullable=True)
    fare = Column(Float, nullable=True)  # in LKR
    current_lat = Column(Float, nullable=True)  # Live GPS latitude
    current_lng = Column(Float, nullable=True)  # Live GPS longitude
    status = Column(String, default="active", nullable=False)  # "active" | "completed"
    started_at = Column(DateTime(timezone=True), default=utc_now)
    ended_at = Column(DateTime(timezone=True), nullable=True)

    truck = relationship("Truck", back_populates="trips")
