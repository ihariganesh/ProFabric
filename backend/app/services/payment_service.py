"""
Payment and Escrow Service

Handles milestone-based payments with escrow functionality for the textile supply chain.
Payment flow:
1. Buyer creates order → Advance payment (30%) escrowed
2. Sample approval → First milestone released
3. Production completion → Second milestone released
4. Quality check passed → Third milestone released
5. Delivery confirmed → Final payment released
"""

from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import and_
from datetime import datetime
import uuid

from app.models.payment import Payment, PaymentType, PaymentStatus
from app.models.order import Order, OrderStatus
from app.models.user import User


# Milestone payment breakdown
MILESTONE_BREAKDOWN = {
    "advance": 0.30,              # 30% on order placement
    "sample_approved": 0.20,      # 20% on sample approval
    "production_complete": 0.25,  # 25% on production completion
    "quality_passed": 0.15,       # 15% on quality check
    "delivered": 0.10,            # 10% on delivery confirmation
}

# Status to milestone mapping
STATUS_MILESTONE_MAP = {
    OrderStatus.PAYMENT_PENDING: "advance",
    OrderStatus.SAMPLE_APPROVED: "sample_approved",
    OrderStatus.PRODUCTION_COMPLETE: "production_complete",
    OrderStatus.QUALITY_APPROVED: "quality_passed",
    OrderStatus.DELIVERED: "delivered",
}


class PaymentService:
    """Service for handling payments and escrow operations"""

    @staticmethod
    def create_escrow_payment(
        db: Session,
        order_id: int,
        payer_id: int,
        payee_id: int,
        amount: float,
        payment_type: PaymentType,
        sub_order_id: Optional[int] = None,
        payment_gateway: str = "stripe",
        currency: str = "INR",
    ) -> Payment:
        """
        Create a new payment in escrow status
        """
        payment = Payment(
            order_id=order_id,
            sub_order_id=sub_order_id,
            payer_id=payer_id,
            payee_id=payee_id,
            amount=amount,
            currency=currency,
            payment_type=payment_type,
            payment_status=PaymentStatus.ESCROWED,
            payment_gateway=payment_gateway,
            transaction_id=f"TXN-{uuid.uuid4().hex[:12].upper()}",
            created_at=datetime.utcnow(),
        )
        db.add(payment)
        db.commit()
        db.refresh(payment)
        return payment

    @staticmethod
    def release_payment(
        db: Session,
        payment_id: int,
        released_by_id: int,
    ) -> Payment:
        """
        Release an escrowed payment to the payee
        """
        payment = db.query(Payment).filter(Payment.payment_id == payment_id).first()
        if not payment:
            raise ValueError(f"Payment {payment_id} not found")
        
        if payment.payment_status != PaymentStatus.ESCROWED:
            raise ValueError(f"Payment {payment_id} is not in escrow status")
        
        payment.payment_status = PaymentStatus.RELEASED
        payment.released_at = datetime.utcnow()
        db.commit()
        db.refresh(payment)
        return payment

    @staticmethod
    def refund_payment(
        db: Session,
        payment_id: int,
        reason: str = None,
    ) -> Payment:
        """
        Refund an escrowed payment back to the payer
        """
        payment = db.query(Payment).filter(Payment.payment_id == payment_id).first()
        if not payment:
            raise ValueError(f"Payment {payment_id} not found")
        
        if payment.payment_status != PaymentStatus.ESCROWED:
            raise ValueError(f"Payment {payment_id} cannot be refunded from {payment.payment_status} status")
        
        payment.payment_status = PaymentStatus.REFUNDED
        payment.released_at = datetime.utcnow()
        db.commit()
        db.refresh(payment)
        return payment

    @staticmethod
    def create_milestone_payments(
        db: Session,
        order: Order,
        total_amount: float,
    ) -> List[Payment]:
        """
        Create all milestone payments for an order in PENDING status
        """
        payments = []
        
        for milestone, percentage in MILESTONE_BREAKDOWN.items():
            milestone_amount = total_amount * percentage
            payment_type = PaymentType.ADVANCE if milestone == "advance" else (
                PaymentType.FINAL if milestone == "delivered" else PaymentType.MILESTONE
            )
            
            payment = Payment(
                order_id=order.order_id,
                payer_id=order.buyer_id,
                payee_id=order.textile_id,  # Initially to textile, will be split later
                amount=milestone_amount,
                currency="INR",
                payment_type=payment_type,
                payment_status=PaymentStatus.PENDING,
                payment_gateway="razorpay",
                transaction_id=f"TXN-{milestone.upper()}-{uuid.uuid4().hex[:8].upper()}",
                created_at=datetime.utcnow(),
            )
            payments.append(payment)
            db.add(payment)
        
        db.commit()
        for p in payments:
            db.refresh(p)
        return payments

    @staticmethod
    def trigger_milestone_payment(
        db: Session,
        order_id: int,
        milestone: str,
    ) -> Optional[Payment]:
        """
        Trigger escrow for a specific milestone when status changes
        """
        # Find the pending payment for this milestone
        payment = db.query(Payment).filter(
            and_(
                Payment.order_id == order_id,
                Payment.transaction_id.like(f"TXN-{milestone.upper()}%"),
                Payment.payment_status == PaymentStatus.PENDING,
            )
        ).first()
        
        if payment:
            payment.payment_status = PaymentStatus.ESCROWED
            db.commit()
            db.refresh(payment)
        
        return payment

    @staticmethod
    def release_milestone_on_status(
        db: Session,
        order_id: int,
        new_status: OrderStatus,
    ) -> Optional[Payment]:
        """
        Auto-release payment when order reaches certain milestones
        """
        milestone = STATUS_MILESTONE_MAP.get(new_status)
        if not milestone:
            return None
        
        # Find escrowed payment for previous milestone to release
        milestone_order = list(MILESTONE_BREAKDOWN.keys())
        current_idx = milestone_order.index(milestone) if milestone in milestone_order else -1
        
        if current_idx > 0:
            prev_milestone = milestone_order[current_idx - 1]
            payment = db.query(Payment).filter(
                and_(
                    Payment.order_id == order_id,
                    Payment.transaction_id.like(f"TXN-{prev_milestone.upper()}%"),
                    Payment.payment_status == PaymentStatus.ESCROWED,
                )
            ).first()
            
            if payment:
                payment.payment_status = PaymentStatus.RELEASED
                payment.released_at = datetime.utcnow()
                db.commit()
                db.refresh(payment)
                return payment
        
        return None

    @staticmethod
    def get_order_payments(
        db: Session,
        order_id: int,
    ) -> List[Payment]:
        """
        Get all payments for an order
        """
        return db.query(Payment).filter(Payment.order_id == order_id).all()

    @staticmethod
    def get_payment_summary(
        db: Session,
        order_id: int,
    ) -> dict:
        """
        Get payment summary for an order
        """
        payments = db.query(Payment).filter(Payment.order_id == order_id).all()
        
        total = sum(p.amount for p in payments)
        pending = sum(p.amount for p in payments if p.payment_status == PaymentStatus.PENDING)
        escrowed = sum(p.amount for p in payments if p.payment_status == PaymentStatus.ESCROWED)
        released = sum(p.amount for p in payments if p.payment_status == PaymentStatus.RELEASED)
        refunded = sum(p.amount for p in payments if p.payment_status == PaymentStatus.REFUNDED)
        
        return {
            "order_id": order_id,
            "total_amount": total,
            "pending_amount": pending,
            "escrowed_amount": escrowed,
            "released_amount": released,
            "refunded_amount": refunded,
            "payments": [
                {
                    "payment_id": p.payment_id,
                    "amount": p.amount,
                    "type": p.payment_type.value if p.payment_type else None,
                    "status": p.payment_status.value if p.payment_status else None,
                    "transaction_id": p.transaction_id,
                    "created_at": p.created_at.isoformat() if p.created_at else None,
                    "released_at": p.released_at.isoformat() if p.released_at else None,
                }
                for p in payments
            ]
        }


class EscrowService:
    """
    High-level escrow operations for order workflow
    """

    @staticmethod
    def initialize_order_escrow(
        db: Session,
        order: Order,
    ) -> Payment:
        """
        Initialize escrow when order is created
        Creates advance payment (30%) in escrow
        """
        advance_amount = order.total_cost * MILESTONE_BREAKDOWN["advance"]
        
        return PaymentService.create_escrow_payment(
            db=db,
            order_id=order.order_id,
            payer_id=order.buyer_id,
            payee_id=order.textile_id,
            amount=advance_amount,
            payment_type=PaymentType.ADVANCE,
            payment_gateway="razorpay",
            currency="INR",
        )

    @staticmethod
    def on_sample_approved(
        db: Session,
        order_id: int,
    ) -> dict:
        """
        Handle payment flow when sample is approved
        - Release advance to textile
        - Create and escrow next milestone payment
        """
        order = db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        # Release advance payment
        advance_payment = db.query(Payment).filter(
            and_(
                Payment.order_id == order_id,
                Payment.payment_type == PaymentType.ADVANCE,
                Payment.payment_status == PaymentStatus.ESCROWED,
            )
        ).first()
        
        released = None
        if advance_payment:
            advance_payment.payment_status = PaymentStatus.RELEASED
            advance_payment.released_at = datetime.utcnow()
            released = advance_payment
        
        # Create sample approval milestone payment
        sample_amount = order.total_cost * MILESTONE_BREAKDOWN["sample_approved"]
        milestone_payment = PaymentService.create_escrow_payment(
            db=db,
            order_id=order_id,
            payer_id=order.buyer_id,
            payee_id=order.textile_id,
            amount=sample_amount,
            payment_type=PaymentType.MILESTONE,
            currency="INR",
        )
        
        db.commit()
        
        return {
            "released_payment": released.payment_id if released else None,
            "released_amount": released.amount if released else 0,
            "new_escrow_payment": milestone_payment.payment_id,
            "escrowed_amount": milestone_payment.amount,
        }

    @staticmethod
    def on_production_complete(
        db: Session,
        order_id: int,
    ) -> dict:
        """
        Handle payment flow when production is complete
        """
        order = db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        # Release previous milestone
        prev_payment = db.query(Payment).filter(
            and_(
                Payment.order_id == order_id,
                Payment.payment_type == PaymentType.MILESTONE,
                Payment.payment_status == PaymentStatus.ESCROWED,
            )
        ).first()
        
        released = None
        if prev_payment:
            prev_payment.payment_status = PaymentStatus.RELEASED
            prev_payment.released_at = datetime.utcnow()
            released = prev_payment
        
        # Create production milestone payment
        prod_amount = order.total_cost * MILESTONE_BREAKDOWN["production_complete"]
        milestone_payment = PaymentService.create_escrow_payment(
            db=db,
            order_id=order_id,
            payer_id=order.buyer_id,
            payee_id=order.textile_id,
            amount=prod_amount,
            payment_type=PaymentType.MILESTONE,
            currency="INR",
        )
        
        db.commit()
        
        return {
            "released_payment": released.payment_id if released else None,
            "released_amount": released.amount if released else 0,
            "new_escrow_payment": milestone_payment.payment_id,
            "escrowed_amount": milestone_payment.amount,
        }

    @staticmethod
    def on_quality_approved(
        db: Session,
        order_id: int,
    ) -> dict:
        """
        Handle payment flow when quality check passes
        """
        order = db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        # Release previous milestone
        prev_payment = db.query(Payment).filter(
            and_(
                Payment.order_id == order_id,
                Payment.payment_type == PaymentType.MILESTONE,
                Payment.payment_status == PaymentStatus.ESCROWED,
            )
        ).order_by(Payment.created_at.desc()).first()
        
        released = None
        if prev_payment:
            prev_payment.payment_status = PaymentStatus.RELEASED
            prev_payment.released_at = datetime.utcnow()
            released = prev_payment
        
        # Create QC milestone payment
        qc_amount = order.total_cost * MILESTONE_BREAKDOWN["quality_passed"]
        milestone_payment = PaymentService.create_escrow_payment(
            db=db,
            order_id=order_id,
            payer_id=order.buyer_id,
            payee_id=order.textile_id,
            amount=qc_amount,
            payment_type=PaymentType.MILESTONE,
            currency="INR",
        )
        
        db.commit()
        
        return {
            "released_payment": released.payment_id if released else None,
            "released_amount": released.amount if released else 0,
            "new_escrow_payment": milestone_payment.payment_id,
            "escrowed_amount": milestone_payment.amount,
        }

    @staticmethod
    def on_delivery_confirmed(
        db: Session,
        order_id: int,
    ) -> dict:
        """
        Handle final payment when delivery is confirmed
        Releases all remaining escrowed payments
        """
        order = db.query(Order).filter(Order.order_id == order_id).first()
        if not order:
            raise ValueError(f"Order {order_id} not found")
        
        # Release all escrowed payments
        escrowed_payments = db.query(Payment).filter(
            and_(
                Payment.order_id == order_id,
                Payment.payment_status == PaymentStatus.ESCROWED,
            )
        ).all()
        
        released_total = 0
        for payment in escrowed_payments:
            payment.payment_status = PaymentStatus.RELEASED
            payment.released_at = datetime.utcnow()
            released_total += payment.amount
        
        # Create final payment
        final_amount = order.total_cost * MILESTONE_BREAKDOWN["delivered"]
        final_payment = PaymentService.create_escrow_payment(
            db=db,
            order_id=order_id,
            payer_id=order.buyer_id,
            payee_id=order.textile_id,
            amount=final_amount,
            payment_type=PaymentType.FINAL,
            currency="INR",
        )
        
        # Immediately release final payment
        final_payment.payment_status = PaymentStatus.RELEASED
        final_payment.released_at = datetime.utcnow()
        
        db.commit()
        
        return {
            "released_count": len(escrowed_payments) + 1,
            "total_released": released_total + final_amount,
            "order_complete": True,
        }

    @staticmethod
    def handle_dispute(
        db: Session,
        order_id: int,
        refund_percentage: float = 0.0,
    ) -> dict:
        """
        Handle payment in case of dispute
        Optionally refund a percentage of escrowed funds
        """
        escrowed_payments = db.query(Payment).filter(
            and_(
                Payment.order_id == order_id,
                Payment.payment_status == PaymentStatus.ESCROWED,
            )
        ).all()
        
        total_escrowed = sum(p.amount for p in escrowed_payments)
        refund_amount = total_escrowed * refund_percentage
        
        results = {
            "escrowed_payments": len(escrowed_payments),
            "total_escrowed": total_escrowed,
            "refund_amount": refund_amount,
            "held_for_resolution": total_escrowed - refund_amount,
            "status": "pending_resolution"
        }
        
        return results
