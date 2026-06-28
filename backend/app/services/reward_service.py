import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from fastapi import HTTPException, status

from app.models.user import User
from app.models.reward import Reward, UserReward, PointTransaction, TransactionType
from app.models.badge import Badge, UserBadge
from app.core.redis import RedisCache


class RewardService:
    def __init__(self, db: AsyncSession, cache: RedisCache):
        self.db = db
        self.cache = cache

    async def get_available_rewards(self) -> list[Reward]:
        """List all active rewards."""
        result = await self.db.execute(
            select(Reward)
            .where(Reward.is_active == True)
            .order_by(Reward.points_cost.asc())
        )
        return list(result.scalars().all())

    async def exchange_reward(
        self,
        user: User,
        reward_id: uuid.UUID,
        quantity: int = 1,
    ) -> UserReward:
        """Exchange points for a reward."""
        # Lock reward row to prevent race conditions
        result = await self.db.execute(
            select(Reward)
            .where(and_(Reward.id == reward_id, Reward.is_active == True))
            .with_for_update()
        )
        reward = result.scalar_one_or_none()

        if not reward:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Reward not found or no longer available",
            )

        total_cost = reward.points_cost * quantity

        if user.available_points < total_cost:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail=f"Insufficient points. Need {total_cost}, have {user.available_points}",
            )

        # Check stock
        if reward.stock_quantity is not None:
            if reward.stock_quantity < quantity:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Insufficient stock",
                )
            reward.stock_quantity -= quantity
            self.db.add(reward)

        # Deduct points
        user.available_points -= total_cost
        self.db.add(user)

        # Record transaction
        transaction = PointTransaction(
            user_id=user.id,
            transaction_type=TransactionType.SPENT_REWARD,
            amount=-total_cost,
            balance_after=user.available_points,
            description=f"Exchanged {quantity}x {reward.name}",
            reference_id=str(reward_id),
        )
        self.db.add(transaction)

        # Record user reward
        user_reward = UserReward(
            user_id=user.id,
            reward_id=reward.id,
            points_spent=total_cost,
            status="pending",
        )
        self.db.add(user_reward)
        await self.db.flush()
        await self.db.refresh(user_reward)
        return user_reward

    async def credit_points(
        self,
        user: User,
        amount: int,
        transaction_type: TransactionType,
        description: str,
        reference_id: str | None = None,
    ) -> PointTransaction:
        """Add points to user's balance."""
        user.total_points += amount
        user.available_points += amount
        self.db.add(user)

        transaction = PointTransaction(
            user_id=user.id,
            transaction_type=transaction_type,
            amount=amount,
            balance_after=user.available_points,
            description=description,
            reference_id=reference_id,
        )
        self.db.add(transaction)
        await self.db.flush()
        return transaction

    async def get_transaction_history(
        self,
        user_id: uuid.UUID,
        page: int = 1,
        size: int = 20,
    ) -> tuple[list[PointTransaction], int]:
        from sqlalchemy import func
        count_result = await self.db.execute(
            select(func.count())
            .select_from(PointTransaction)
            .where(PointTransaction.user_id == user_id)
        )
        total = count_result.scalar_one()

        result = await self.db.execute(
            select(PointTransaction)
            .where(PointTransaction.user_id == user_id)
            .order_by(PointTransaction.created_at.desc())
            .offset((page - 1) * size)
            .limit(size)
        )
        return list(result.scalars().all()), total

    async def award_badge(self, user: User, badge_name: str) -> UserBadge | None:
        """Award a badge to user if they don't already have it."""
        # Find badge
        badge_result = await self.db.execute(
            select(Badge).where(
                and_(Badge.name == badge_name, Badge.is_active == True)
            )
        )
        badge = badge_result.scalar_one_or_none()
        if not badge:
            return None

        # Check if already awarded
        existing = await self.db.execute(
            select(UserBadge).where(
                and_(
                    UserBadge.user_id == user.id,
                    UserBadge.badge_id == badge.id,
                )
            )
        )
        if existing.scalar_one_or_none():
            return None

        user_badge = UserBadge(user_id=user.id, badge_id=badge.id)
        self.db.add(user_badge)

        # Award badge points
        if badge.points_reward > 0:
            await self.credit_points(
                user=user,
                amount=badge.points_reward,
                transaction_type=TransactionType.EARNED_BADGE,
                description=f"Badge earned: {badge.name}",
                reference_id=str(badge.id),
            )

        await self.db.flush()
        return user_badge

    async def check_and_award_badges(self, user: User) -> list[str]:
        """Check all badge criteria and award any earned badges."""
        awarded = []

        # Streak badges
        streak_badges = {
            3: "3일 연속 공부",
            7: "7일 연속 공부",
            30: "30일 연속 공부",
            100: "100일 연속 공부",
        }
        for days, badge_name in streak_badges.items():
            if user.streak_days >= days:
                result = await self.award_badge(user, badge_name)
                if result:
                    awarded.append(badge_name)

        # Study time badges
        hour_badges = {
            10: "10시간 공부",
            50: "50시간 공부",
            100: "100시간 공부",
            500: "500시간 공부",
        }
        for hours, badge_name in hour_badges.items():
            if user.total_study_hours >= hours:
                result = await self.award_badge(user, badge_name)
                if result:
                    awarded.append(badge_name)

        return awarded
