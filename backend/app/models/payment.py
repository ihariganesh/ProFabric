from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.core.database import Base


class PaymentType(str, enum.Enum):
    ADVANCE = "Advance"
    MILESTONE = "Milestone"
    FINAL = "Final"
    REFUND = "Refund"


class PaymentStatus(str, enum.Enum):
    PENDING = "Pending"
    ESCROWED = "Escrowed"
    RELEASED = "Released"
    FAILED = "Failed"
    REFUNDED = "Refunded"


class Payment(Base):
    __tablename__ = "payments"

    payment_id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.order_id"), index=True)
    sub_order_id = Column(Integer, ForeignKey("sub_orders.sub_order_id"), index=True)
    payer_id = Column(Integer, ForeignKey("users.user_id"), index=True)
    payee_id = Column(Integer, ForeignKey("users.user_id"), index=True)
    amount = Column(Float, nullable=False)
    currency = Column(String(3), default="USD")
    payment_type = Column(Enum(PaymentType))
    payment_status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING)
    payment_gateway = Column(String(100))  # Stripe, Razorpay, etc.
    transaction_id = Column(String(255), unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    released_at = Column(DateTime)

    # Relationships
    order = relationship("Order", back_populates="payments")
    sub_order = relationship("SubOrder", back_populates="payments")
    payer = relationship("User", back_populates="payments_made", foreign_keys=[payer_id])
    payee = relationship("User", back_populates="payments_received", foreign_keys=[payee_id])

    def __repr__(self):
        return f"<Payment {self.payment_id} - {self.amount} {self.currency} - {self.payment_status}>"
