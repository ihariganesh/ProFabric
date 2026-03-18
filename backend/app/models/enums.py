from enum import Enum

class UserRole(str, Enum):
    BUYER = "Buyer"
    TEXTILE_HUB = "Textile Hub"
    SUPPLY_PARTNER = "Supply Partner"
    ADMIN = "Admin"

class SupplyPartnerType(str, Enum):
    YARN_MANUFACTURER = "Yarn Manufacturer"
    WEAVER = "Weaver"
    FABRIC_SELLER = "Fabric Seller"
    PRINTING_UNIT = "Printing Unit"
    STITCHING_UNIT = "Stitching Unit"
    LOGISTICS_PROVIDER = "Logistics Provider"

class OrderState(str, Enum):
    CREATED = "CREATED"
    SAMPLE_REQUESTED = "SAMPLE_REQUESTED"
    SAMPLE_SENT = "SAMPLE_SENT"
    SAMPLE_APPROVED = "SAMPLE_APPROVED"
    FABRIC_SOURCED = "FABRIC_SOURCED"
    PRINTING = "PRINTING"
    STITCHING = "STITCHING"
    PACKAGING = "PACKAGING"
    SHIPPED = "SHIPPED"
    DELIVERED = "DELIVERED"
