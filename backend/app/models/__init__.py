from app.core.database import Base

# Import all models here for Alembic to detect them
from app.models.user import User
from app.models.product import ProductService
from app.models.order import Order, BillOfMaterial, SubOrder
from app.models.shipment import Shipment
from app.models.message import Message
from app.models.notification import Notification
from app.models.payment import Payment
from app.models.rating import VendorRating

__all__ = [
    "Base",
    "User",
    "ProductService",
    "Order",
    "BillOfMaterial",
    "SubOrder",
    "Shipment",
    "Message",
    "Notification",
    "Payment",
    "VendorRating"
]
