import logging
from typing import Dict, Any
from app.models.enums import OrderState, UserRole

logger = logging.getLogger(__name__)

class WorkflowException(Exception):
    pass

class WorkflowEngine:
    """
    Finite State Machine for managing multi-role Order Lifecycle.
    Enforces strict role-based state transitions and triggers side-effects (e.g. AI simulations).
    """

    # Define allowed transitions and the role required to trigger them
    TRANSITIONS = {
        OrderState.CREATED: {
            "next": OrderState.SAMPLE_REQUESTED,
            "allowed_roles": [UserRole.BUYER, UserRole.TEXTILE_HUB]
        },
        OrderState.SAMPLE_REQUESTED: {
            "next": OrderState.SAMPLE_SENT,
            "allowed_roles": [UserRole.SUPPLY_PARTNER, UserRole.TEXTILE_HUB]
        },
        OrderState.SAMPLE_SENT: {
            "next": OrderState.SAMPLE_APPROVED,
            "allowed_roles": [UserRole.BUYER]
        },
        OrderState.SAMPLE_APPROVED: {
            "next": OrderState.FABRIC_SOURCED,
            "allowed_roles": [UserRole.TEXTILE_HUB]
        },
        OrderState.FABRIC_SOURCED: {
            "next": OrderState.PRINTING,
            "allowed_roles": [UserRole.SUPPLY_PARTNER, UserRole.TEXTILE_HUB]
        },
        OrderState.PRINTING: {
            "next": OrderState.STITCHING,
            "allowed_roles": [UserRole.SUPPLY_PARTNER, UserRole.TEXTILE_HUB]
        },
        OrderState.STITCHING: {
            "next": OrderState.PACKAGING,
            "allowed_roles": [UserRole.SUPPLY_PARTNER, UserRole.TEXTILE_HUB]
        },
        OrderState.PACKAGING: {
            "next": OrderState.SHIPPED,
            "allowed_roles": [UserRole.SUPPLY_PARTNER, UserRole.TEXTILE_HUB]
        },
        OrderState.SHIPPED: {
            "next": OrderState.DELIVERED,
            "allowed_roles": [UserRole.SUPPLY_PARTNER]  # specifically logistics
        },
        OrderState.DELIVERED: {
            "next": None,  # Terminal state
            "allowed_roles": []
        }
    }

    @staticmethod
    async def process_transition(current_state: OrderState, action_role: UserRole, context: Dict[str, Any]) -> OrderState:
        """
        Attempts to transition the order from current_state to the next state, verifying role permissions.
        Triggers corresponding side-effects (notifs, AI pipelines) on successful transition.
        """
        config = WorkflowEngine.TRANSITIONS.get(current_state)
        if not config:
            raise WorkflowException(f"Unknown state: {current_state}")
            
        next_state = config["next"]
        if not next_state:
            raise WorkflowException("Cannot transition from terminal state.")
            
        if action_role not in config["allowed_roles"] and action_role != UserRole.ADMIN:
            raise WorkflowException(f"Role {action_role} is not authorized to transition from {current_state}")

        logger.info(f"Transitioning order from {current_state} -> {next_state}")
        
        # Trigger side-effects based on the new state
        await WorkflowEngine._trigger_side_effects(next_state, context)
        
        return next_state

    @staticmethod
    async def _trigger_side_effects(new_state: OrderState, context: Dict[str, Any]):
        """
        Fire events for AI evaluation or notifications based on state entered.
        """
        if new_state == OrderState.SAMPLE_REQUESTED:
            # Trigger FabricSim prediction & RiskRadar
            pass
        elif new_state in [OrderState.PRINTING, OrderState.STITCHING]:
            # Expecting EdgeGuard live QC feed initiation
            pass
        elif new_state == OrderState.SHIPPED:
            # Activate logistics tracing
            pass
