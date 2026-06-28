import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

from app.models.reward import TransactionType


class RewardRead(BaseModel):
    id: uuid.UUID
    name: str
    description: str
    image_url: Optional[str] = None
    category: str
    points_cost: int
    stock_quantity: Optional[int] = None
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class RewardExchangeRequest(BaseModel):
    reward_id: uuid.UUID
    quantity: int = Field(default=1, ge=1, le=10)


class RewardExchangeResponse(BaseModel):
    user_reward_id: uuid.UUID
    reward: RewardRead
    points_spent: int
    remaining_points: int
    status: str
    message: str


class PointTransactionRead(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    transaction_type: TransactionType
    amount: int
    balance_after: int
    description: str
    reference_id: Optional[str] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class PointTransactionListResponse(BaseModel):
    transactions: list[PointTransactionRead]
    total: int
    page: int
    size: int


class BadgeRead(BaseModel):
    id: uuid.UUID
    name: str
    description: str
    icon_url: Optional[str] = None
    category: str
    points_reward: int
    rarity: str
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class UserBadgeRead(BaseModel):
    badge: BadgeRead
    earned_at: datetime

    model_config = {"from_attributes": True}
