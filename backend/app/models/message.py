from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime

from app.core.database import Base


class Message(Base):
    __tablename__ = "messages"

    message_id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.order_id"), index=True)
    sender_id = Column(Integer, ForeignKey("users.user_id"), index=True)
    receiver_id = Column(Integer, ForeignKey("users.user_id"), index=True)
    message_text = Column(Text, nullable=False)
    attachment_url = Column(Text)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    # Relationships
    order = relationship("Order", back_populates="messages")
    sender = relationship("User", back_populates="sent_messages", foreign_keys=[sender_id])
    receiver = relationship("User", back_populates="received_messages", foreign_keys=[receiver_id])

    def __repr__(self):
        return f"<Message {self.message_id} from {self.sender_id} to {self.receiver_id}>"
