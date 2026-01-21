from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, JSON, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.core.database import Base


class UserRole(str, enum.Enum):
    BUYER = "Buyer"
    MATERIAL_VENDOR = "MaterialVendor"
    FACTORY = "Factory"
    LOGISTICS = "Logistics"


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    role = Column(Enum(UserRole), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(Text, nullable=False)
    phone = Column(String(20))
    rating = Column(Float, default=0.0, index=True)
    location_data = Column(JSON)  # {lat, lng, address, city, state, country}
    profile_image_url = Column(Text)
    business_name = Column(String(255))
    business_registration_no = Column(String(100))
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    orders = relationship("Order", back_populates="buyer", foreign_keys="Order.buyer_id")
    products_services = relationship("ProductService", back_populates="vendor")
    sub_orders = relationship("SubOrder", back_populates="vendor")
    shipments = relationship("Shipment", back_populates="logistics_provider")
    sent_messages = relationship("Message", back_populates="sender", foreign_keys="Message.sender_id")
    received_messages = relationship("Message", back_populates="receiver", foreign_keys="Message.receiver_id")
    notifications = relationship("Notification", back_populates="user")
    payments_made = relationship("Payment", back_populates="payer", foreign_keys="Payment.payer_id")
    payments_received = relationship("Payment", back_populates="payee", foreign_keys="Payment.payee_id")
    ratings_given = relationship("VendorRating", back_populates="rater", foreign_keys="VendorRating.rated_by")
    ratings_received = relationship("VendorRating", back_populates="vendor", foreign_keys="VendorRating.vendor_id")

    def __repr__(self):
        return f"<User {self.name} ({self.role})>"
