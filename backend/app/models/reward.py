import uuid
import enum
from datetime import datetime
from sqlalchemy import (
    String, Integer, DateTime, ForeignKey, func, Text,
    Boolean, Enum, JSON
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class TransactionType(str, enum.Enum):
    EARNED_STUDY = "earned_study"          # Points from study session
    EARNED_BADGE = "earned_badge"          # Points from earning a badge
    EARNED_STREAK = "earned_streak"        # Streak bonus points
    EARNED_REFERRAL = "earned_referral"    # Referral bonus
    SPENT_REWARD = "spent_reward"          # Spent on reward exchange
    SPENT_BOOST = "spent_boost"            # Spent on temporary boost
    ADMIN_GRANT = "admin_grant"            # Manually granted by admin
    ADMIN_DEDUCT = "admin_deduct"          # Manually deducted by admin
    EXPIRED = "expired"                    # Points expired


class Reward(Base):
    """Available rewards that users can exchange points for."""
    __tablename__ = "rewards"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    name: Mapped[str] = mapped_column(
        String(200),
        nullable=False,
    )
    description: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )
    image_url: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )
    category: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        comment="gift_card, merchandise, digital, subscription",
    )

    # Pricing
    points_cost: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="Points required to exchange for this reward",
    )
    stock_quantity: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
        comment="NULL means unlimited stock",
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )
    metadata_json: Mapped[dict | None] = mapped_column(
        JSON,
        nullable=True,
        comment="Additional reward metadata (e.g., gift card codes)",
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    user_rewards: Mapped[list["UserReward"]] = relationship(
        "UserReward",
        back_populates="reward",
        lazy="dynamic",
    )

    def __repr__(self) -> str:
        return f"<Reward id={self.id} name={self.name} cost={self.points_cost}>"


class UserReward(Base):
    """Records of rewards exchanged by users."""
    __tablename__ = "user_rewards"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    reward_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("rewards.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    points_spent: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )
    status: Mapped[str] = mapped_column(
        String(20),
        default="pending",
        nullable=False,
        comment="pending, fulfilled, cancelled",
    )
    fulfillment_data: Mapped[dict | None] = mapped_column(
        JSON,
        nullable=True,
        comment="Fulfillment details (e.g., gift card code)",
    )
    exchanged_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    fulfilled_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )

    # Relationships
    user: Mapped["User"] = relationship("User")
    reward: Mapped["Reward"] = relationship(
        "Reward",
        back_populates="user_rewards",
    )

    def __repr__(self) -> str:
        return f"<UserReward user={self.user_id} reward={self.reward_id}>"


class PointTransaction(Base):
    """Complete audit log of all point transactions."""
    __tablename__ = "point_transactions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    transaction_type: Mapped[TransactionType] = mapped_column(
        Enum(TransactionType),
        nullable=False,
        index=True,
    )
    amount: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="Positive = earned, Negative = spent",
    )
    balance_after: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="User's available points balance after this transaction",
    )
    description: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
    )
    reference_id: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
        comment="ID of related entity (session_id, reward_id, etc.)",
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        back_populates="point_transactions",
    )

    def __repr__(self) -> str:
        return (
            f"<PointTransaction user={self.user_id} "
            f"type={self.transaction_type} amount={self.amount}>"
        )
