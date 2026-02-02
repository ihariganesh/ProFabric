from sqlalchemy import Column, Integer, String, Float, DateTime, Text, ForeignKey, Enum, JSON, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.core.database import Base


class OrderStatus(str, enum.Enum):
    """
    Complete Order State Machine for Textile Supply Chain
    
    BUYER JOURNEY:
    CREATED → DESIGN_PROCESSING → TEXTILE_SELECTION → SAMPLE_REQUESTED → 
    SAMPLE_SENT → SAMPLE_APPROVED/REJECTED → ...
    
    PRODUCTION JOURNEY:
    → FABRIC_SOURCING → PRINTING_IN_PROGRESS → PRINTING_COMPLETED →
    → STITCHING_IN_PROGRESS → PACKAGING → QUALITY_CHECK → ...
    
    DELIVERY JOURNEY:
    → READY_FOR_SHIPMENT → SHIPPED → IN_TRANSIT → OUT_FOR_DELIVERY → DELIVERED
    
    EXCEPTION STATES:
    CANCELLED, DISPUTED, REFUNDED, ON_HOLD
    """
    # Initial States
    CREATED = "Created"
    DESIGN_PROCESSING = "DesignProcessing"  # AI analyzing design
    DESIGN_READY = "DesignReady"
    
    # Textile Selection Phase
    TEXTILE_BIDDING = "TextileBidding"  # Multiple textiles can bid
    TEXTILE_SELECTED = "TextileSelected"
    
    # Sample Phase
    SAMPLE_REQUESTED = "SampleRequested"
    SAMPLE_IN_PRODUCTION = "SampleInProduction"
    SAMPLE_SENT = "SampleSent"
    SAMPLE_DELIVERED = "SampleDelivered"
    SAMPLE_APPROVED = "SampleApproved"
    SAMPLE_REJECTED = "SampleRejected"
    
    # Production Phase
    FABRIC_SOURCING = "FabricSourcing"
    FABRIC_SOURCED = "FabricSourced"
    PRINTING_PENDING = "PrintingPending"
    PRINTING_IN_PROGRESS = "PrintingInProgress"
    PRINTING_COMPLETED = "PrintingCompleted"
    STITCHING_PENDING = "StitchingPending"
    STITCHING_IN_PROGRESS = "StitchingInProgress"
    STITCHING_COMPLETED = "StitchingCompleted"
    
    # Quality & Packaging
    QUALITY_CHECK_PENDING = "QualityCheckPending"
    QUALITY_CHECK_IN_PROGRESS = "QualityCheckInProgress"
    QUALITY_APPROVED = "QualityApproved"
    QUALITY_REJECTED = "QualityRejected"
    PACKAGING = "Packaging"
    PACKAGING_COMPLETED = "PackagingCompleted"
    
    # Delivery Phase
    READY_FOR_SHIPMENT = "ReadyForShipment"
    PICKUP_SCHEDULED = "PickupScheduled"
    PICKED_UP = "PickedUp"
    IN_TRANSIT = "InTransit"
    AT_HUB = "AtHub"
    OUT_FOR_DELIVERY = "OutForDelivery"
    DELIVERED = "Delivered"
    
    # Exception States
    ON_HOLD = "OnHold"
    CANCELLED = "Cancelled"
    DISPUTED = "Disputed"
    REFUNDED = "Refunded"
    
    # Legacy statuses for backward compatibility
    PENDING = "Pending"
    ANALYZING = "Analyzing"
    BIDDING = "Bidding"
    ACCEPTED = "Accepted"
    PRODUCTION = "Production"
    SHIPPING = "Shipping"


# State Machine Transitions - defines valid state changes
ORDER_STATE_TRANSITIONS = {
    OrderStatus.CREATED: [OrderStatus.DESIGN_PROCESSING, OrderStatus.CANCELLED],
    OrderStatus.DESIGN_PROCESSING: [OrderStatus.DESIGN_READY, OrderStatus.CANCELLED],
    OrderStatus.DESIGN_READY: [OrderStatus.TEXTILE_BIDDING, OrderStatus.CANCELLED],
    OrderStatus.TEXTILE_BIDDING: [OrderStatus.TEXTILE_SELECTED, OrderStatus.CANCELLED],
    OrderStatus.TEXTILE_SELECTED: [OrderStatus.SAMPLE_REQUESTED, OrderStatus.CANCELLED],
    OrderStatus.SAMPLE_REQUESTED: [OrderStatus.SAMPLE_IN_PRODUCTION, OrderStatus.CANCELLED],
    OrderStatus.SAMPLE_IN_PRODUCTION: [OrderStatus.SAMPLE_SENT, OrderStatus.CANCELLED],
    OrderStatus.SAMPLE_SENT: [OrderStatus.SAMPLE_DELIVERED, OrderStatus.CANCELLED],
    OrderStatus.SAMPLE_DELIVERED: [OrderStatus.SAMPLE_APPROVED, OrderStatus.SAMPLE_REJECTED],
    OrderStatus.SAMPLE_APPROVED: [OrderStatus.FABRIC_SOURCING],
    OrderStatus.SAMPLE_REJECTED: [OrderStatus.SAMPLE_IN_PRODUCTION, OrderStatus.CANCELLED, OrderStatus.REFUNDED],
    OrderStatus.FABRIC_SOURCING: [OrderStatus.FABRIC_SOURCED, OrderStatus.ON_HOLD],
    OrderStatus.FABRIC_SOURCED: [OrderStatus.PRINTING_PENDING],
    OrderStatus.PRINTING_PENDING: [OrderStatus.PRINTING_IN_PROGRESS, OrderStatus.ON_HOLD],
    OrderStatus.PRINTING_IN_PROGRESS: [OrderStatus.PRINTING_COMPLETED, OrderStatus.ON_HOLD],
    OrderStatus.PRINTING_COMPLETED: [OrderStatus.STITCHING_PENDING],
    OrderStatus.STITCHING_PENDING: [OrderStatus.STITCHING_IN_PROGRESS, OrderStatus.ON_HOLD],
    OrderStatus.STITCHING_IN_PROGRESS: [OrderStatus.STITCHING_COMPLETED, OrderStatus.ON_HOLD],
    OrderStatus.STITCHING_COMPLETED: [OrderStatus.QUALITY_CHECK_PENDING],
    OrderStatus.QUALITY_CHECK_PENDING: [OrderStatus.QUALITY_CHECK_IN_PROGRESS],
    OrderStatus.QUALITY_CHECK_IN_PROGRESS: [OrderStatus.QUALITY_APPROVED, OrderStatus.QUALITY_REJECTED],
    OrderStatus.QUALITY_APPROVED: [OrderStatus.PACKAGING],
    OrderStatus.QUALITY_REJECTED: [OrderStatus.STITCHING_PENDING, OrderStatus.PRINTING_PENDING],
    OrderStatus.PACKAGING: [OrderStatus.PACKAGING_COMPLETED],
    OrderStatus.PACKAGING_COMPLETED: [OrderStatus.READY_FOR_SHIPMENT],
    OrderStatus.READY_FOR_SHIPMENT: [OrderStatus.PICKUP_SCHEDULED],
    OrderStatus.PICKUP_SCHEDULED: [OrderStatus.PICKED_UP],
    OrderStatus.PICKED_UP: [OrderStatus.IN_TRANSIT],
    OrderStatus.IN_TRANSIT: [OrderStatus.AT_HUB, OrderStatus.OUT_FOR_DELIVERY],
    OrderStatus.AT_HUB: [OrderStatus.IN_TRANSIT, OrderStatus.OUT_FOR_DELIVERY],
    OrderStatus.OUT_FOR_DELIVERY: [OrderStatus.DELIVERED, OrderStatus.AT_HUB],
    OrderStatus.DELIVERED: [OrderStatus.DISPUTED],
    OrderStatus.ON_HOLD: [OrderStatus.FABRIC_SOURCING, OrderStatus.PRINTING_PENDING, OrderStatus.STITCHING_PENDING, OrderStatus.CANCELLED],
    OrderStatus.DISPUTED: [OrderStatus.REFUNDED, OrderStatus.DELIVERED],
}


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
