import pytest
from fastapi.testclient import TestClient
from main import app
from database import Base, engine, SessionLocal

client = TestClient(app)


@pytest.fixture(autouse=True)
def reset_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield


def test_create_and_list_trucks():
    # Create truck
    response = client.post("/trucks", json={
        "plate_number": "WP CAD-1001",
        "driver_name": "Ruwan Perera",
        "rate_per_km": 200.0
    })
    assert response.status_code == 201
    data = response.json()
    assert data["plate_number"] == "WP CAD-1001"
    assert data["driver_name"] == "Ruwan Perera"
    assert data["rate_per_km"] == 200.0
    truck_id = data["id"]

    # Duplicate plate check
    response_dup = client.post("/trucks", json={
        "plate_number": "WP CAD-1001",
        "driver_name": "Another Driver",
        "rate_per_km": 150.0
    })
    assert response_dup.status_code == 400

    # List trucks
    response_list = client.get("/trucks")
    assert response_list.status_code == 200
    trucks = response_list.json()
    assert len(trucks) == 1
    assert trucks[0]["id"] == truck_id


def test_trip_lifecycle_and_fare_calculation():
    # 1. Create a truck
    t_resp = client.post("/trucks", json={
        "plate_number": "SP ND-2020",
        "driver_name": "Saman Jayawardena",
        "rate_per_km": 150.0
    })
    truck_id = t_resp.json()["id"]

    # 2. Start a trip
    trip_req = client.post("/trips/start", json={
        "truck_id": truck_id,
        "start_location": "Colombo",
        "end_location": "Galle"
    })
    assert trip_req.status_code == 201
    trip = trip_req.json()
    assert trip["status"] == "active"
    assert trip["truck_id"] == truck_id
    assert trip["distance_km"] is None
    assert trip["fare"] is None
    trip_id = trip["id"]

    # 3. Attempt starting a 2nd active trip for same truck (should fail)
    trip_dup = client.post("/trips/start", json={
        "truck_id": truck_id,
        "start_location": "Galle",
        "end_location": "Matara"
    })
    assert trip_dup.status_code == 400

    # 4. Check active trips endpoint
    active_resp = client.get("/trips/active")
    assert active_resp.status_code == 200
    active_trips = active_resp.json()
    assert len(active_trips) == 1
    assert active_trips[0]["id"] == trip_id

    # 5. End trip with 120 km -> fare should be 120 * 150.0 = 18000.0 LKR
    end_resp = client.post(f"/trips/{trip_id}/end", json={"distance_km": 120.0})
    assert end_resp.status_code == 200
    completed_trip = end_resp.json()
    assert completed_trip["status"] == "completed"
    assert completed_trip["distance_km"] == 120.0
    assert completed_trip["fare"] == 18000.0
    assert completed_trip["ended_at"] is not None

    # 6. Attempt ending an already completed trip (should fail)
    end_dup = client.post(f"/trips/{trip_id}/end", json={"distance_km": 10.0})
    assert end_dup.status_code == 400

    # 7. Check active trips endpoint after completion (should be empty)
    active_resp2 = client.get("/trips/active")
    assert len(active_resp2.json()) == 0

    # 8. Check all trips list (should contain 1 completed trip)
    all_trips = client.get("/trips").json()
    assert len(all_trips) == 1
    assert all_trips[0]["status"] == "completed"


if __name__ == "__main__":
    pytest.main(["-v", __file__])
