from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, JSON, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.core.database import Base


class ProductType(str, enum.Enum):
    THREAD = "Thread"
    DYE = "Dye"
    CHEMICAL = "Chemical"
    WEAVING_SERVICE = "WeavingService"
    KNITTING_SERVICE = "KnittingService"
    DYEING_SERVICE = "DyeingService"
    FINISHING_SERVICE = "FinishingService"
    TRANSPORT_SERVICE = "TransportService"
    QUALITY_CHECK_SERVICE = "QualityCheckService"


class ProductService(Base):
    __tablename__ = "products_services"

    item_id = Column(Integer, primary_key=True, index=True)
    vendor_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    type = Column(Enum(ProductType), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    price_per_unit = Column(Float, nullable=False)
    unit = Column(String(50), nullable=False)  # kg, meters, service, trip
    max_capacity = Column(Integer)
    min_order_quantity = Column(Integer, default=1)
    lead_time_days = Column(Integer, nullable=False)
    specifications = Column(JSON)  # Material specs, certifications, etc.
    is_available = Column(Boolean, default=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    vendor = relationship("User", back_populates="products_services")

    def __repr__(self):
        return f"<ProductService {self.name} ({self.type})>"
