from sqlalchemy import Column, Integer, Float, DateTime, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime

from app.core.database import Base


class VendorRating(Base):
    __tablename__ = "vendor_ratings"

    rating_id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.order_id"), index=True)
    vendor_id = Column(Integer, ForeignKey("users.user_id"), index=True)
    rated_by = Column(Integer, ForeignKey("users.user_id"), index=True)
    rating = Column(Float, nullable=False)  # 0-5
    review_text = Column(Text)
    criteria = Column(JSON)  # {quality: 4.5, speed: 5, communication: 4}
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    order = relationship("Order", back_populates="ratings")
    vendor = relationship("User", back_populates="ratings_received", foreign_keys=[vendor_id])
    rater = relationship("User", back_populates="ratings_given", foreign_keys=[rated_by])

    def __repr__(self):
        return f"<VendorRating {self.rating_id} - {self.rating}/5>"
