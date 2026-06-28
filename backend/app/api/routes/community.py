import uuid
import math
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, update

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache
from app.models.user import User
from app.models.community import Post, Comment, PostLike, CommentLike, PostCategory
from app.schemas.community import (
    PostCreate, PostUpdate, PostRead, PostListResponse,
    CommentCreate, CommentUpdate, CommentRead,
)

router = APIRouter(prefix="/community", tags=["Community"])


# ─────────────── Posts ───────────────

@router.post(
    "/posts",
    response_model=PostRead,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new post",
)
async def create_post(
    data: PostCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    post = Post(
        author_id=current_user.id,
        title=data.title,
        content=data.content,
        category=data.category,
    )
    db.add(post)
    await db.flush()
    await db.refresh(post)
    return PostRead.model_validate(post)


@router.get(
    "/posts",
    response_model=PostListResponse,
    summary="List community posts",
)
async def list_posts(
    page: int = Query(default=1, ge=1),
    size: int = Query(default=20, ge=1, le=100),
    category: Optional[PostCategory] = None,
    search: Optional[str] = Query(default=None, max_length=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(Post).where(Post.is_deleted == False)
    count_q = select(func.count()).select_from(Post).where(Post.is_deleted == False)

    if category:
        query = query.where(Post.category == category)
        count_q = count_q.where(Post.category == category)
    if search:
        like = f"%{search}%"
        query = query.where(Post.title.ilike(like) | Post.content.ilike(like))
        count_q = count_q.where(Post.title.ilike(like) | Post.content.ilike(like))

    total = (await db.execute(count_q)).scalar_one()
    posts = (await db.execute(
        query.order_by(Post.is_pinned.desc(), Post.created_at.desc())
        .offset((page - 1) * size)
        .limit(size)
    )).scalars().all()

    return PostListResponse(
        posts=[PostRead.model_validate(p) for p in posts],
        total=total,
        page=page,
        size=size,
        total_pages=math.ceil(total / size) if total else 0,
    )


@router.get(
    "/posts/{post_id}",
    response_model=PostRead,
    summary="Get post by ID",
)
async def get_post(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    post = await _get_post_or_404(db, post_id)

    # Increment view count
    await db.execute(
        update(Post).where(Post.id == post_id).values(view_count=Post.view_count + 1)
    )

    result = PostRead.model_validate(post)

    # Check if current user liked this post
    like = await db.execute(
        select(PostLike).where(
            and_(PostLike.post_id == post_id, PostLike.user_id == current_user.id)
        )
    )
    result.is_liked = like.scalar_one_or_none() is not None
    return result


@router.put(
    "/posts/{post_id}",
    response_model=PostRead,
    summary="Update a post",
)
async def update_post(
    post_id: uuid.UUID,
    data: PostUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    post = await _get_post_or_404(db, post_id)
    _require_author(post.author_id, current_user.id)

    for field, value in data.model_dump(exclude_none=True).items():
        setattr(post, field, value)

    db.add(post)
    await db.flush()
    await db.refresh(post)
    return PostRead.model_validate(post)


@router.delete(
    "/posts/{post_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a post",
)
async def delete_post(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    post = await _get_post_or_404(db, post_id)
    _require_author_or_admin(post.author_id, current_user)
    post.is_deleted = True
    db.add(post)


@router.post(
    "/posts/{post_id}/like",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Toggle like on a post",
)
async def toggle_post_like(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    post = await _get_post_or_404(db, post_id)

    existing = await db.execute(
        select(PostLike).where(
            and_(PostLike.post_id == post_id, PostLike.user_id == current_user.id)
        )
    )
    like = existing.scalar_one_or_none()

    if like:
        await db.delete(like)
        post.like_count = max(0, post.like_count - 1)
    else:
        db.add(PostLike(user_id=current_user.id, post_id=post_id))
        post.like_count += 1

    db.add(post)


# ─────────────── Comments ───────────────

@router.post(
    "/posts/{post_id}/comments",
    response_model=CommentRead,
    status_code=status.HTTP_201_CREATED,
    summary="Add a comment to a post",
)
async def create_comment(
    post_id: uuid.UUID,
    data: CommentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    post = await _get_post_or_404(db, post_id)

    if data.parent_id:
        parent_result = await db.execute(
            select(Comment).where(
                and_(Comment.id == data.parent_id, Comment.post_id == post_id)
            )
        )
        if not parent_result.scalar_one_or_none():
            raise HTTPException(status_code=404, detail="Parent comment not found")

    comment = Comment(
        post_id=post_id,
        author_id=current_user.id,
        content=data.content,
        parent_id=data.parent_id,
    )
    db.add(comment)
    post.comment_count += 1
    db.add(post)
    await db.flush()
    await db.refresh(comment)
    return CommentRead.model_validate(comment)


@router.get(
    "/posts/{post_id}/comments",
    response_model=list[CommentRead],
    summary="Get comments for a post",
)
async def list_comments(
    post_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Comment).where(
            and_(
                Comment.post_id == post_id,
                Comment.parent_id.is_(None),
                Comment.is_deleted == False,
            )
        ).order_by(Comment.created_at.asc())
    )
    return [CommentRead.model_validate(c) for c in result.scalars().all()]


@router.put(
    "/comments/{comment_id}",
    response_model=CommentRead,
    summary="Update a comment",
)
async def update_comment(
    comment_id: uuid.UUID,
    data: CommentUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    comment = await _get_comment_or_404(db, comment_id)
    _require_author(comment.author_id, current_user.id)
    comment.content = data.content
    db.add(comment)
    await db.flush()
    await db.refresh(comment)
    return CommentRead.model_validate(comment)


@router.delete(
    "/comments/{comment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a comment",
)
async def delete_comment(
    comment_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    comment = await _get_comment_or_404(db, comment_id)
    _require_author_or_admin(comment.author_id, current_user)
    comment.is_deleted = True
    db.add(comment)


# ─────────────── Helpers ───────────────

async def _get_post_or_404(db: AsyncSession, post_id: uuid.UUID) -> Post:
    result = await db.execute(
        select(Post).where(and_(Post.id == post_id, Post.is_deleted == False))
    )
    post = result.scalar_one_or_none()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    return post


async def _get_comment_or_404(db: AsyncSession, comment_id: uuid.UUID) -> Comment:
    result = await db.execute(
        select(Comment).where(and_(Comment.id == comment_id, Comment.is_deleted == False))
    )
    comment = result.scalar_one_or_none()
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")
    return comment


def _require_author(resource_author_id: uuid.UUID, user_id: uuid.UUID) -> None:
    if resource_author_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")


def _require_author_or_admin(resource_author_id: uuid.UUID, user: User) -> None:
    from app.models.user import UserRole
    if resource_author_id != user.id and user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="Not authorized")
