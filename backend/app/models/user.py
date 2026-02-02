from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, JSON, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.core.database import Base


class UserRole(str, enum.Enum):
    """
    9 Core User Roles for the Textile Supply Chain Platform
    
    1. BUYER - Retail & Wholesale buyers who place orders
    2. TEXTILE - Orchestrator/Manufacturer who manages the entire production workflow
    3. FABRIC_SELLER - Sells fabric to textiles or other parties
    4. WEAVER - Produces fabric from yarn
    5. YARN_MANUFACTURER - Produces and sells yarn
    6. PRINTING_UNIT - Handles fabric printing/processing
    7. STITCHING_UNIT - Handles stitching and packaging
    8. LOGISTICS - Handles transportation and delivery
    9. ADMIN - Platform administrator
    """
    BUYER = "Buyer"
    TEXTILE = "Textile"  # Core Orchestrator Role
    FABRIC_SELLER = "FabricSeller"
    WEAVER = "Weaver"
    YARN_MANUFACTURER = "YarnManufacturer"
    PRINTING_UNIT = "PrintingUnit"
    STITCHING_UNIT = "StitchingUnit"
    LOGISTICS = "Logistics"
    ADMIN = "Admin"
    
    # Legacy aliases for backward compatibility
    MATERIAL_VENDOR = "MaterialVendor"  # Deprecated: Use specific vendor types
    FACTORY = "Factory"  # Deprecated: Use TEXTILE


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
