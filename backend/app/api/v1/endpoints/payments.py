"""
Payment API Endpoints

Handles payment operations including escrow management, milestone payments,
and payment status queries.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
from pydantic import BaseModel
from datetime import datetime

from app.core.database import get_db
from app.models.payment import Payment, PaymentStatus, PaymentType
from app.models.order import Order
from app.services.payment_service import PaymentService, EscrowService


router = APIRouter()


# Request/Response Models
class CreatePaymentRequest(BaseModel):
    order_id: int
    sub_order_id: Optional[int] = None
    payer_id: int
    payee_id: int
    amount: float
    currency: str = "INR"
    payment_type: str = "Milestone"
    payment_gateway: str = "razorpay"


class PaymentResponse(BaseModel):
    payment_id: int
    order_id: int
    amount: float
    currency: str
    payment_type: Optional[str]
    payment_status: str
    transaction_id: Optional[str]
    created_at: Optional[datetime]
    released_at: Optional[datetime]

    class Config:
        from_attributes = True


class PaymentSummaryResponse(BaseModel):
    order_id: int
    total_amount: float
    pending_amount: float
    escrowed_amount: float
    released_amount: float
    refunded_amount: float
    payments: list


class MilestonePaymentRequest(BaseModel):
    order_id: int
    milestone: str


# Routes

@router.get("/order/{order_id}", response_model=PaymentSummaryResponse)
def get_order_payments(
    order_id: int,
    db: Session = Depends(get_db),
):
    """Get all payments and summary for an order"""
    order = db.query(Order).filter(Order.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    summary = PaymentService.get_payment_summary(db, order_id)
    return summary


@router.get("/{payment_id}", response_model=PaymentResponse)
def get_payment(
    payment_id: int,
    db: Session = Depends(get_db),
):
    """Get a specific payment by ID"""
    payment = db.query(Payment).filter(Payment.payment_id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    return PaymentResponse(
        payment_id=payment.payment_id,
        order_id=payment.order_id,
        amount=payment.amount,
        currency=payment.currency,
        payment_type=payment.payment_type.value if payment.payment_type else None,
        payment_status=payment.payment_status.value if payment.payment_status else "Unknown",
        transaction_id=payment.transaction_id,
        created_at=payment.created_at,
        released_at=payment.released_at,
    )


@router.post("/escrow/create", response_model=PaymentResponse)
def create_escrow_payment(
    request: CreatePaymentRequest,
    db: Session = Depends(get_db),
):
    """Create a new payment in escrow status"""
    order = db.query(Order).filter(Order.order_id == request.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    payment_type = PaymentType[request.payment_type.upper()] if request.payment_type else PaymentType.MILESTONE
    
    payment = PaymentService.create_escrow_payment(
        db=db,
        order_id=request.order_id,
        sub_order_id=request.sub_order_id,
        payer_id=request.payer_id,
        payee_id=request.payee_id,
        amount=request.amount,
        payment_type=payment_type,
        payment_gateway=request.payment_gateway,
        currency=request.currency,
    )
    
    return PaymentResponse(
        payment_id=payment.payment_id,
        order_id=payment.order_id,
        amount=payment.amount,
        currency=payment.currency,
        payment_type=payment.payment_type.value if payment.payment_type else None,
        payment_status=payment.payment_status.value if payment.payment_status else "Unknown",
        transaction_id=payment.transaction_id,
        created_at=payment.created_at,
        released_at=payment.released_at,
    )


@router.post("/{payment_id}/release")
def release_payment(
    payment_id: int,
    released_by_id: int,
    db: Session = Depends(get_db),
):
    """Release an escrowed payment to the payee"""
    try:
        payment = PaymentService.release_payment(
            db=db,
            payment_id=payment_id,
            released_by_id=released_by_id,
        )
        return {
            "success": True,
            "message": f"Payment {payment_id} released successfully",
            "payment_id": payment.payment_id,
            "amount": payment.amount,
            "released_at": payment.released_at.isoformat() if payment.released_at else None,
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{payment_id}/refund")
def refund_payment(
    payment_id: int,
    reason: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """Refund an escrowed payment back to the payer"""
    try:
        payment = PaymentService.refund_payment(
            db=db,
            payment_id=payment_id,
            reason=reason,
        )
        return {
            "success": True,
            "message": f"Payment {payment_id} refunded successfully",
            "payment_id": payment.payment_id,
            "amount": payment.amount,
            "refunded_at": payment.released_at.isoformat() if payment.released_at else None,
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


# Milestone-based payment endpoints

@router.post("/milestone/initialize/{order_id}")
def initialize_order_escrow(
    order_id: int,
    db: Session = Depends(get_db),
):
    """Initialize escrow for a new order (creates advance payment)"""
    order = db.query(Order).filter(Order.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if not order.total_cost:
        raise HTTPException(status_code=400, detail="Order has no total cost set")
    
    try:
        payment = EscrowService.initialize_order_escrow(db, order)
        return {
            "success": True,
            "message": "Order escrow initialized",
            "payment_id": payment.payment_id,
            "advance_amount": payment.amount,
            "transaction_id": payment.transaction_id,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/milestone/sample-approved/{order_id}")
def on_sample_approved(
    order_id: int,
    db: Session = Depends(get_db),
):
    """Trigger payment flow when sample is approved"""
    try:
        result = EscrowService.on_sample_approved(db, order_id)
        return {"success": True, "message": "Sample approval payment processed", **result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/milestone/production-complete/{order_id}")
def on_production_complete(
    order_id: int,
    db: Session = Depends(get_db),
):
    """Trigger payment flow when production is complete"""
    try:
        result = EscrowService.on_production_complete(db, order_id)
        return {"success": True, "message": "Production completion payment processed", **result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/milestone/quality-approved/{order_id}")
def on_quality_approved(
    order_id: int,
    db: Session = Depends(get_db),
):
    """Trigger payment flow when quality check passes"""
    try:
        result = EscrowService.on_quality_approved(db, order_id)
        return {"success": True, "message": "Quality approval payment processed", **result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/milestone/delivery-confirmed/{order_id}")
def on_delivery_confirmed(
    order_id: int,
    db: Session = Depends(get_db),
):
    """Trigger final payment flow when delivery is confirmed"""
    try:
        result = EscrowService.on_delivery_confirmed(db, order_id)
        return {"success": True, "message": "Delivery confirmed - all payments released", **result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/dispute/{order_id}")
def handle_dispute(
    order_id: int,
    refund_percentage: float = 0.0,
    db: Session = Depends(get_db),
):
    """Handle payment in case of dispute"""
    if refund_percentage < 0 or refund_percentage > 1:
        raise HTTPException(status_code=400, detail="Refund percentage must be between 0 and 1")
    
    try:
        result = EscrowService.handle_dispute(db, order_id, refund_percentage)
        return {"success": True, "message": "Dispute handling initiated", **result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


# User payment endpoints

@router.get("/user/{user_id}/made")
def get_payments_made(
    user_id: int,
    status_filter: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """Get all payments made by a user"""
    query = db.query(Payment).filter(Payment.payer_id == user_id)
    
    if status_filter:
        try:
            payment_status = PaymentStatus[status_filter.upper()]
            query = query.filter(Payment.payment_status == payment_status)
        except KeyError:
            pass
    
    payments = query.order_by(Payment.created_at.desc()).all()
    
    return {
        "user_id": user_id,
        "payment_count": len(payments),
        "total_amount": sum(p.amount for p in payments),
        "payments": [
            {
                "payment_id": p.payment_id,
                "order_id": p.order_id,
                "amount": p.amount,
                "status": p.payment_status.value if p.payment_status else None,
                "type": p.payment_type.value if p.payment_type else None,
                "created_at": p.created_at.isoformat() if p.created_at else None,
            }
            for p in payments
        ]
    }


@router.get("/user/{user_id}/received")
def get_payments_received(
    user_id: int,
    status_filter: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """Get all payments received by a user"""
    query = db.query(Payment).filter(Payment.payee_id == user_id)
    
    if status_filter:
        try:
            payment_status = PaymentStatus[status_filter.upper()]
            query = query.filter(Payment.payment_status == payment_status)
        except KeyError:
            pass
    
    payments = query.order_by(Payment.created_at.desc()).all()
    
    return {
        "user_id": user_id,
        "payment_count": len(payments),
        "total_amount": sum(p.amount for p in payments),
        "released_amount": sum(p.amount for p in payments if p.payment_status == PaymentStatus.RELEASED),
        "pending_amount": sum(p.amount for p in payments if p.payment_status in [PaymentStatus.PENDING, PaymentStatus.ESCROWED]),
        "payments": [
            {
                "payment_id": p.payment_id,
                "order_id": p.order_id,
                "amount": p.amount,
                "status": p.payment_status.value if p.payment_status else None,
                "type": p.payment_type.value if p.payment_type else None,
                "created_at": p.created_at.isoformat() if p.created_at else None,
                "released_at": p.released_at.isoformat() if p.released_at else None,
            }
            for p in payments
        ]
    }
