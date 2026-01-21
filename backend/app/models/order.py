from sqlalchemy import Column, Integer, String, Float, DateTime, Text, ForeignKey, Enum, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.core.database import Base


class OrderStatus(str, enum.Enum):
    PENDING = "Pending"
    ANALYZING = "Analyzing"
    BIDDING = "Bidding"
    ACCEPTED = "Accepted"
    PRODUCTION = "Production"
    SHIPPING = "Shipping"
    DELIVERED = "Delivered"
    CANCELLED = "Cancelled"
    DISPUTED = "Disputed"


class TaskType(str, enum.Enum):
    SUPPLY_MATERIAL = "Supply_Material"
    MANUFACTURE = "Manufacture"
    WEAVING = "Weaving"
    KNITTING = "Knitting"
    DYEING = "Dyeing"
    FINISHING = "Finishing"
    QUALITY_CHECK = "Quality_Check"
    PACKAGING = "Packaging"
    TRANSPORT = "Transport"


class SubOrderStatus(str, enum.Enum):
    OFFERED = "Offered"
    ACCEPTED = "Accepted"
    REJECTED = "Rejected"
    IN_PROGRESS = "In_Progress"
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"


class Order(Base):
    __tablename__ = "orders"

    order_id = Column(Integer, primary_key=True, index=True)
    buyer_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    design_prompt = Column(Text)
    generated_image_url = Column(Text)
    fabric_type = Column(String(100), nullable=False)
    quantity_meters = Column(Integer, nullable=False)
    thread_count = Column(Integer)
    gsm = Column(Integer)  # Grams per square meter
    status = Column(Enum(OrderStatus), default=OrderStatus.PENDING, nullable=False, index=True)
    total_cost = Column(Float)
    optimization_score = Column(Float)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    estimated_delivery = Column(DateTime)
    actual_delivery = Column(DateTime)

    # Relationships
    buyer = relationship("User", back_populates="orders", foreign_keys=[buyer_id])
    bill_of_materials = relationship("BillOfMaterial", back_populates="order", cascade="all, delete-orphan")
    sub_orders = relationship("SubOrder", back_populates="parent_order", cascade="all, delete-orphan")
    messages = relationship("Message", back_populates="order")
    payments = relationship("Payment", back_populates="order")
    ratings = relationship("VendorRating", back_populates="order")

    def __repr__(self):
        return f"<Order {self.order_id} - {self.status}>"


class BillOfMaterial(Base):
    __tablename__ = "bill_of_materials"

    bom_id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.order_id", ondelete="CASCADE"), index=True)
    material_name = Column(String(255), nullable=False)
    material_type = Column(String(100), nullable=False)
    quantity_required = Column(Float, nullable=False)
    unit = Column(String(50), nullable=False)
    estimated_cost = Column(Float)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    order = relationship("Order", back_populates="bill_of_materials")

    def __repr__(self):
        return f"<BOM {self.material_name} - {self.quantity_required}{self.unit}>"


class SubOrder(Base):
    __tablename__ = "sub_orders"

    sub_order_id = Column(Integer, primary_key=True, index=True)
    parent_order_id = Column(Integer, ForeignKey("orders.order_id", ondelete="CASCADE"), index=True)
    assigned_vendor_id = Column(Integer, ForeignKey("users.user_id"), index=True)
    task_type = Column(Enum(TaskType), nullable=False)
    task_description = Column(Text)
    agreed_cost = Column(Float)
    status = Column(Enum(SubOrderStatus), default=SubOrderStatus.OFFERED, nullable=False, index=True)
    offered_at = Column(DateTime, default=datetime.utcnow)
    accepted_at = Column(DateTime)
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    sequence_order = Column(Integer, nullable=False, index=True)
    dependencies = Column(JSON)  # Array of sub_order_ids that must complete first
    notes = Column(Text)

    # Relationships
    parent_order = relationship("Order", back_populates="sub_orders")
    vendor = relationship("User", back_populates="sub_orders")
    shipments = relationship("Shipment", back_populates="sub_order")
    payments = relationship("Payment", back_populates="sub_order")

    def __repr__(self):
        return f"<SubOrder {self.sub_order_id} - {self.task_type} - {self.status}>"
