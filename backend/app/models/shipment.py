from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, Enum, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.core.database import Base


class ShipmentStatus(str, enum.Enum):
    PENDING_PICKUP = "Pending_Pickup"
    PICKED_UP = "Picked_Up"
    IN_TRANSIT = "In_Transit"
    AT_CHECKPOINT = "At_Checkpoint"
    OUT_FOR_DELIVERY = "Out_For_Delivery"
    DELIVERED = "Delivered"
    FAILED = "Failed"
    RETURNED = "Returned"


class Shipment(Base):
    __tablename__ = "shipments"

    shipment_id = Column(Integer, primary_key=True, index=True)
    related_sub_order_id = Column(Integer, ForeignKey("sub_orders.sub_order_id"), index=True)
    logistics_provider_id = Column(Integer, ForeignKey("users.user_id"), index=True)
    tracking_number = Column(String(100), unique=True, index=True)
    pickup_location = Column(Text, nullable=False)
    pickup_coordinates = Column(JSON)  # {lat, lng}
    drop_location = Column(Text, nullable=False)
    drop_coordinates = Column(JSON)  # {lat, lng}
    current_status = Column(
        Enum(ShipmentStatus),
        default=ShipmentStatus.PENDING_PICKUP,
        nullable=False,
        index=True
    )
    gps_checkpoints = Column(JSON)  # Array of {lat, lng, timestamp, location_name}
    vehicle_info = Column(JSON)  # {type, number, driver_name, driver_phone}
    estimated_pickup = Column(DateTime)
    actual_pickup = Column(DateTime)
    estimated_delivery = Column(DateTime)
    actual_delivery = Column(DateTime)
    delivery_proof_url = Column(Text)  # Photo/signature
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    sub_order = relationship("SubOrder", back_populates="shipments")
    logistics_provider = relationship("User", back_populates="shipments")

    def __repr__(self):
        return f"<Shipment {self.tracking_number} - {self.current_status}>"
