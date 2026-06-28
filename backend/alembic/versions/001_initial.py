"""Initial migration - create all tables

Revision ID: 001
Revises:
Create Date: 2024-01-01 00:00:00.000000
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ─── users ───
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("username", sa.String(50), nullable=False),
        sa.Column("nickname", sa.String(50), nullable=False),
        sa.Column("hashed_password", sa.String(255), nullable=False),
        sa.Column("profile_image_url", sa.String(500), nullable=True),
        sa.Column("bio", sa.Text, nullable=True),
        sa.Column("level", sa.Integer, nullable=False, server_default="1"),
        sa.Column("total_study_hours", sa.Float, nullable=False, server_default="0"),
        sa.Column("certified_study_hours", sa.Float, nullable=False, server_default="0"),
        sa.Column("streak_days", sa.Integer, nullable=False, server_default="0"),
        sa.Column("max_streak_days", sa.Integer, nullable=False, server_default="0"),
        sa.Column("last_study_date", sa.DateTime(timezone=True), nullable=True),
        sa.Column("total_points", sa.Integer, nullable=False, server_default="0"),
        sa.Column("available_points", sa.Integer, nullable=False, server_default="0"),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("is_verified", sa.Boolean, nullable=False, server_default="false"),
        sa.Column(
            "role",
            sa.Enum("user", "admin", "moderator", name="userrole"),
            nullable=False,
            server_default="user",
        ),
        sa.Column("push_notifications_enabled", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("email_notifications_enabled", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("firebase_token", sa.String(500), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )
    op.create_index("ix_users_id", "users", ["id"])
    op.create_index("ix_users_email", "users", ["email"], unique=True)
    op.create_index("ix_users_username", "users", ["username"], unique=True)

    # ─── study_sessions ───
    op.create_table(
        "study_sessions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "subject",
            sa.Enum("수학", "영어", "국어", "과학", "사회", "기타", name="subject"),
            nullable=False,
        ),
        sa.Column("title", sa.String(200), nullable=True),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("duration_seconds", sa.Integer, nullable=False, server_default="0"),
        sa.Column("certified_duration_seconds", sa.Integer, nullable=False, server_default="0"),
        sa.Column("ai_score", sa.Float, nullable=True),
        sa.Column("face_detected_ratio", sa.Float, nullable=True),
        sa.Column("gaze_ratio", sa.Float, nullable=True),
        sa.Column("absence_ratio", sa.Float, nullable=True),
        sa.Column("phone_detected_ratio", sa.Float, nullable=True),
        sa.Column("drowsy_ratio", sa.Float, nullable=True),
        sa.Column("total_frames_analyzed", sa.Integer, nullable=False, server_default="0"),
        sa.Column(
            "certification_status",
            sa.Enum(
                "pending", "processing", "certified", "partial", "rejected", "failed",
                name="certificationstatus",
            ),
            nullable=False,
            server_default="pending",
        ),
        sa.Column("points_earned", sa.Integer, nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_study_sessions_id", "study_sessions", ["id"])
    op.create_index("ix_study_sessions_user_id", "study_sessions", ["user_id"])
    op.create_index("ix_study_sessions_certification_status", "study_sessions", ["certification_status"])

    # ─── ai_reports ───
    op.create_table(
        "ai_reports",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("study_session_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("overall_score", sa.Float, nullable=False),
        sa.Column("attention_score", sa.Float, nullable=False),
        sa.Column("consistency_score", sa.Float, nullable=False),
        sa.Column("face_detected_ratio", sa.Float, nullable=False),
        sa.Column("gaze_ratio", sa.Float, nullable=False),
        sa.Column("absence_ratio", sa.Float, nullable=False),
        sa.Column("phone_detected_ratio", sa.Float, nullable=False),
        sa.Column("drowsy_ratio", sa.Float, nullable=False),
        sa.Column("total_frames", sa.Integer, nullable=False, server_default="0"),
        sa.Column("valid_frames", sa.Integer, nullable=False, server_default="0"),
        sa.Column("alert_frames", sa.Integer, nullable=False, server_default="0"),
        sa.Column("focused_time_seconds", sa.Integer, server_default="0"),
        sa.Column("distracted_time_seconds", sa.Integer, server_default="0"),
        sa.Column("absent_time_seconds", sa.Integer, server_default="0"),
        sa.Column("drowsy_time_seconds", sa.Integer, server_default="0"),
        sa.Column("phone_time_seconds", sa.Integer, server_default="0"),
        sa.Column("feedback_summary", sa.Text, nullable=True),
        sa.Column("improvement_tips", postgresql.JSON, nullable=True),
        sa.Column("strengths", postgresql.JSON, nullable=True),
        sa.Column("attention_timeline", postgresql.JSON, nullable=True),
        sa.Column("certified_minutes", sa.Integer, server_default="0"),
        sa.Column("analyzed_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["study_session_id"], ["study_sessions.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("study_session_id", name="uq_ai_reports_study_session_id"),
    )
    op.create_index("ix_ai_reports_id", "ai_reports", ["id"])
    op.create_index("ix_ai_reports_user_id", "ai_reports", ["user_id"])
    op.create_index("ix_ai_reports_study_session_id", "ai_reports", ["study_session_id"])

    # ─── badges ───
    op.create_table(
        "badges",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False, unique=True),
        sa.Column("description", sa.Text, nullable=False),
        sa.Column("icon_url", sa.String(500), nullable=True),
        sa.Column("category", sa.String(50), nullable=False),
        sa.Column("criteria", postgresql.JSON, nullable=True),
        sa.Column("points_reward", sa.Integer, nullable=False, server_default="0"),
        sa.Column("rarity", sa.String(20), nullable=False, server_default="common"),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_badges_id", "badges", ["id"])

    # ─── user_badges ───
    op.create_table(
        "user_badges",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("badge_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("earned_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["badge_id"], ["badges.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_user_badges_user_id", "user_badges", ["user_id"])
    op.create_index("ix_user_badges_badge_id", "user_badges", ["badge_id"])

    # ─── rewards ───
    op.create_table(
        "rewards",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(200), nullable=False),
        sa.Column("description", sa.Text, nullable=False),
        sa.Column("image_url", sa.String(500), nullable=True),
        sa.Column("category", sa.String(50), nullable=False),
        sa.Column("points_cost", sa.Integer, nullable=False),
        sa.Column("stock_quantity", sa.Integer, nullable=True),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("metadata_json", postgresql.JSON, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_rewards_id", "rewards", ["id"])

    # ─── user_rewards ───
    op.create_table(
        "user_rewards",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reward_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("points_spent", sa.Integer, nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("fulfillment_data", postgresql.JSON, nullable=True),
        sa.Column("exchanged_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("fulfilled_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["reward_id"], ["rewards.id"], ondelete="RESTRICT"),
    )
    op.create_index("ix_user_rewards_user_id", "user_rewards", ["user_id"])
    op.create_index("ix_user_rewards_reward_id", "user_rewards", ["reward_id"])

    # ─── point_transactions ───
    op.create_table(
        "point_transactions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "transaction_type",
            sa.Enum(
                "earned_study", "earned_badge", "earned_streak", "earned_referral",
                "spent_reward", "spent_boost", "admin_grant", "admin_deduct", "expired",
                name="transactiontype",
            ),
            nullable=False,
        ),
        sa.Column("amount", sa.Integer, nullable=False),
        sa.Column("balance_after", sa.Integer, nullable=False),
        sa.Column("description", sa.String(500), nullable=False),
        sa.Column("reference_id", sa.String(100), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_point_transactions_id", "point_transactions", ["id"])
    op.create_index("ix_point_transactions_user_id", "point_transactions", ["user_id"])
    op.create_index("ix_point_transactions_transaction_type", "point_transactions", ["transaction_type"])

    # ─── posts ───
    op.create_table(
        "posts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("author_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("title", sa.String(300), nullable=False),
        sa.Column("content", sa.Text, nullable=False),
        sa.Column(
            "category",
            sa.Enum("study_tip", "question", "achievement", "motivation", "resource", "free", name="postcategory"),
            nullable=False,
            server_default="free",
        ),
        sa.Column("image_urls_json", postgresql.JSON, nullable=True),
        sa.Column("view_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("like_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("comment_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("is_pinned", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("is_deleted", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("is_reported", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["author_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_posts_id", "posts", ["id"])
    op.create_index("ix_posts_author_id", "posts", ["author_id"])
    op.create_index("ix_posts_category", "posts", ["category"])
    op.create_index("ix_posts_created_at", "posts", ["created_at"])

    # ─── comments ───
    op.create_table(
        "comments",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("post_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("author_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("parent_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("content", sa.Text, nullable=False),
        sa.Column("like_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("is_deleted", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["post_id"], ["posts.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["author_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["parent_id"], ["comments.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_comments_id", "comments", ["id"])
    op.create_index("ix_comments_post_id", "comments", ["post_id"])
    op.create_index("ix_comments_author_id", "comments", ["author_id"])

    # ─── post_likes ───
    op.create_table(
        "post_likes",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("post_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["post_id"], ["posts.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "post_id", name="uq_post_likes_user_post"),
    )

    # ─── comment_likes ───
    op.create_table(
        "comment_likes",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("comment_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["comment_id"], ["comments.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "comment_id", name="uq_comment_likes_user_comment"),
    )

    # ─── crews ───
    op.create_table(
        "crews",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("leader_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("name", sa.String(100), nullable=False, unique=True),
        sa.Column("description", sa.Text, nullable=True),
        sa.Column("icon_url", sa.String(500), nullable=True),
        sa.Column("banner_url", sa.String(500), nullable=True),
        sa.Column("is_public", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("requires_approval", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("max_members", sa.Integer, nullable=False, server_default="50"),
        sa.Column("min_weekly_study_hours", sa.Float, nullable=False, server_default="0"),
        sa.Column("member_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("total_study_hours", sa.Float, nullable=False, server_default="0"),
        sa.Column("weekly_study_hours", sa.Float, nullable=False, server_default="0"),
        sa.Column("average_ai_score", sa.Float, nullable=False, server_default="0"),
        sa.Column("subjects_json", postgresql.JSON, nullable=True),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["leader_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_crews_id", "crews", ["id"])
    op.create_index("ix_crews_leader_id", "crews", ["leader_id"])

    # ─── crew_members ───
    op.create_table(
        "crew_members",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("crew_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column(
            "role",
            sa.Enum("leader", "moderator", "member", name="crewmemberrole"),
            nullable=False,
            server_default="member",
        ),
        sa.Column("status", sa.String(20), nullable=False, server_default="active"),
        sa.Column("contribution_hours", sa.Float, nullable=False, server_default="0"),
        sa.Column("joined_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["crew_id"], ["crews.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "crew_id", name="uq_crew_members_user_crew"),
    )
    op.create_index("ix_crew_members_user_id", "crew_members", ["user_id"])
    op.create_index("ix_crew_members_crew_id", "crew_members", ["crew_id"])


def downgrade() -> None:
    op.drop_table("crew_members")
    op.drop_table("crews")
    op.drop_table("comment_likes")
    op.drop_table("post_likes")
    op.drop_table("comments")
    op.drop_table("posts")
    op.drop_table("point_transactions")
    op.drop_table("user_rewards")
    op.drop_table("rewards")
    op.drop_table("user_badges")
    op.drop_table("badges")
    op.drop_table("ai_reports")
    op.drop_table("study_sessions")
    op.drop_table("users")

    # Drop enums
    op.execute("DROP TYPE IF EXISTS crewmemberrole")
    op.execute("DROP TYPE IF EXISTS postcategory")
    op.execute("DROP TYPE IF EXISTS transactiontype")
    op.execute("DROP TYPE IF EXISTS certificationstatus")
    op.execute("DROP TYPE IF EXISTS subject")
    op.execute("DROP TYPE IF EXISTS userrole")
