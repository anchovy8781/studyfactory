import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

from app.models.community import PostCategory
from app.schemas.user import UserPublic


class PostCreate(BaseModel):
    title: str = Field(..., min_length=2, max_length=300)
    content: str = Field(..., min_length=1, max_length=10000)
    category: PostCategory = PostCategory.FREE
    image_urls: Optional[list[str]] = Field(None, max_length=5)


class PostUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=2, max_length=300)
    content: Optional[str] = Field(None, min_length=1, max_length=10000)
    category: Optional[PostCategory] = None
    image_urls: Optional[list[str]] = Field(None, max_length=5)


class PostRead(BaseModel):
    id: uuid.UUID
    author_id: uuid.UUID
    author: Optional[UserPublic] = None
    title: str
    content: str
    category: PostCategory
    image_urls: Optional[list[str]] = None
    view_count: int
    like_count: int
    comment_count: int
    is_pinned: bool
    is_liked: bool = False  # Populated based on current user
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class PostListResponse(BaseModel):
    posts: list[PostRead]
    total: int
    page: int
    size: int
    total_pages: int


class CommentCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)
    parent_id: Optional[uuid.UUID] = None


class CommentUpdate(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class CommentRead(BaseModel):
    id: uuid.UUID
    post_id: uuid.UUID
    author_id: uuid.UUID
    author: Optional[UserPublic] = None
    parent_id: Optional[uuid.UUID] = None
    content: str
    like_count: int
    is_liked: bool = False
    replies: list["CommentRead"] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# Allow self-reference in CommentRead
CommentRead.model_rebuild()


class CrewCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    description: Optional[str] = Field(None, max_length=1000)
    is_public: bool = True
    requires_approval: bool = False
    max_members: int = Field(default=50, ge=2, le=200)
    min_weekly_study_hours: float = Field(default=0.0, ge=0.0, le=168.0)
    subjects: Optional[list[str]] = None


class CrewUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    description: Optional[str] = Field(None, max_length=1000)
    is_public: Optional[bool] = None
    requires_approval: Optional[bool] = None
    max_members: Optional[int] = Field(None, ge=2, le=200)
    min_weekly_study_hours: Optional[float] = Field(None, ge=0.0, le=168.0)
    subjects: Optional[list[str]] = None


class CrewRead(BaseModel):
    id: uuid.UUID
    leader_id: uuid.UUID
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    banner_url: Optional[str] = None
    is_public: bool
    requires_approval: bool
    max_members: int
    min_weekly_study_hours: float
    member_count: int
    total_study_hours: float
    weekly_study_hours: float
    average_ai_score: float
    subjects: Optional[list[str]] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class CrewMemberRead(BaseModel):
    user_id: uuid.UUID
    crew_id: uuid.UUID
    user: Optional[UserPublic] = None
    role: str
    status: str
    contribution_hours: float
    joined_at: datetime

    model_config = {"from_attributes": True}
