from datetime import datetime, timezone, timedelta
from database import engine, SessionLocal, Base
import models


def seed_database():
    # Ensure tables exist
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # Clear existing data
        db.query(models.Trip).delete()
        db.query(models.Truck).delete()
        db.commit()

        print("--> Seeding initial truck profiles...")
        truck1 = models.Truck(plate_number="WP CAD-1024", driver_name="Kamal Perera", rate_per_km=180.0)
        truck2 = models.Truck(plate_number="SP ND-4509", driver_name="Sunil Shantha", rate_per_km=220.0)
        truck3 = models.Truck(plate_number="CP LA-8812", driver_name="Nimal Fernando", rate_per_km=150.0)
        truck4 = models.Truck(plate_number="WP GA-3390", driver_name="Anura Jayasinghe", rate_per_km=200.0)

        db.add_all([truck1, truck2, truck3, truck4])
        db.commit()

        # Refresh to get IDs
        db.refresh(truck1)
        db.refresh(truck2)
        db.refresh(truck3)
        db.refresh(truck4)

        print(f"    Created Truck ID {truck1.id}: {truck1.plate_number} ({truck1.driver_name}) @ LKR {truck1.rate_per_km}/km")
        print(f"    Created Truck ID {truck2.id}: {truck2.plate_number} ({truck2.driver_name}) @ LKR {truck2.rate_per_km}/km")
        print(f"    Created Truck ID {truck3.id}: {truck3.plate_number} ({truck3.driver_name}) @ LKR {truck3.rate_per_km}/km")
        print(f"    Created Truck ID {truck4.id}: {truck4.plate_number} ({truck4.driver_name}) @ LKR {truck4.rate_per_km}/km")

        print("--> Seeding sample trips...")
        now = datetime.now(timezone.utc)

        # Completed trip for truck1
        trip1_start = now - timedelta(hours=5)
        trip1_end = now - timedelta(hours=2)
        dist1 = 115.0
        fare1 = round(dist1 * truck1.rate_per_km, 2)
        trip1 = models.Trip(
            truck_id=truck1.id,
            start_location="Colombo Fort",
            end_location="Kandy Town",
            distance_km=dist1,
            fare=fare1,
            status="completed",
            started_at=trip1_start,
            ended_at=trip1_end,
        )

        # Active trip for truck2 (Galle -> Hambantota)
        trip2_start = now - timedelta(hours=1)
        trip2 = models.Trip(
            truck_id=truck2.id,
            start_location="Galle Port",
            end_location="Hambantota Logistics Hub",
            status="active",
            current_lat=6.0535,
            current_lng=80.2210,
            started_at=trip2_start,
        )

        # Active trip for truck3 (Nuwara Eliya -> Dambulla)
        trip3_start = now - timedelta(minutes=30)
        trip3 = models.Trip(
            truck_id=truck3.id,
            start_location="Nuwara Eliya Central",
            end_location="Dambulla Economic Centre",
            status="active",
            current_lat=6.9497,
            current_lng=80.7891,
            started_at=trip3_start,
        )

        db.add_all([trip1, trip2, trip3])
        db.commit()

        print("--> Seeding completed successfully!")
        print(f"    1 Completed Trip (Colombo -> Kandy, LKR {fare1})")
        print(f"    2 Active Trips (Galle -> Hambantota, Nuwara Eliya -> Dambulla)")

    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
