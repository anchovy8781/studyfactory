# Firebase 보안 규칙 (Firebase Console에 게시 필요)

아래는 **관리자(isAdmin) 구조를 유지**하면서, 앱이 쓰는 모든 컬렉션
(댓글·포인트내역·성적·학습기록·신고·랭킹 등)을 포함한 완성 규칙입니다.
기존 규칙을 이 내용으로 교체한 뒤 **게시(Publish)** 하세요.

## Firestore 규칙 (Firestore Database → 규칙)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isAdmin() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // 사용자 문서 (본인/관리자만) + 본인 전용 하위 컬렉션
    match /users/{uid} {
      allow read:   if isSignedIn() && (request.auth.uid == uid || isAdmin());
      allow create: if isSignedIn() && request.auth.uid == uid;
      allow update: if isSignedIn() && (request.auth.uid == uid || isAdmin());
      allow delete: if isAdmin() || request.auth.uid == uid;

      match /pointHistory/{doc}   { allow read, write: if isSignedIn() && request.auth.uid == uid; }
      match /grades/{doc}         { allow read, write: if isSignedIn() && request.auth.uid == uid; }
      match /studySessions/{doc}  { allow read, write: if isSignedIn() && request.auth.uid == uid; }
    }

    // 공개 랭킹 (닉네임 + 이번 달 공부시간만 — 민감정보 없음)
    match /leaderboard/{uid} {
      allow read:  if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == uid;
    }

    // 커뮤니티 게시글 + 댓글
    match /posts/{postId} {
      allow read:   if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.authorId == request.auth.uid;
      allow update: if isSignedIn();                       // 좋아요·신고수·댓글수
      allow delete: if isSignedIn() && (resource.data.authorId == request.auth.uid || isAdmin());

      // ★ 댓글 — 이 블록이 없어서 댓글이 막혔던 부분
      match /comments/{commentId} {
        allow read:   if isSignedIn();
        allow create: if isSignedIn() && request.resource.data.authorId == request.auth.uid;
        allow delete: if isSignedIn() && (resource.data.authorId == request.auth.uid || isAdmin());
      }
    }

    // 커뮤니티 신고
    match /reports/{id} {
      allow create: if isSignedIn();
      allow read, update, delete: if isAdmin();
    }

    // 푸드카드 교환 (보낸 사람이 생성, 양쪽이 수락/취소)
    match /trades/{id} {
      allow read:   if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.fromUid == request.auth.uid;
      allow update: if isSignedIn() &&
        (resource.data.fromUid == request.auth.uid ||
         resource.data.toUid == request.auth.uid);
    }

    // 실시간 공부 대결 (호스트가 생성, 참가·진행상황 갱신)
    match /battles/{id} {
      allow read:   if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.hostUid == request.auth.uid;
      allow update: if isSignedIn();  // 참가 + 실시간 진행 동기화
      allow delete: if isSignedIn() && resource.data.hostUid == request.auth.uid;
    }

    // 이벤트 / 월간 랭킹 결과 (읽기 전용)
    match /events/{doc}         { allow read: if isSignedIn(); allow write: if isAdmin(); }
    match /rankingHistory/{doc} { allow read: if isSignedIn(); allow write: if false; }

    // 탈퇴 기록
    match /withdrawals/{id} {
      allow read:  if isAdmin();
      allow write: if isSignedIn() && request.auth.uid == id;
    }

    // 앱 설정(서버 관리 키 등) — 읽기는 로그인 사용자, 수정은 관리자만
    match /config/{doc} {
      allow read:  if isSignedIn();
      allow write: if isAdmin();
    }
  }
}
```

> 핵심: Firestore에서 **하위 컬렉션은 상위 규칙을 상속하지 않습니다.**
> `posts` 안의 `comments`, `users` 안의 `pointHistory`/`grades`/`studySessions`는
> 각각 `match` 블록을 따로 적어줘야 동작합니다.

### 복합 색인(자동 생성)

카드 교환·대결 목록은 복합 조건 쿼리를 사용합니다. 앱에서 처음 열 때 콘솔에
"색인 필요" 오류 링크가 나오면 클릭 한 번으로 생성하면 됩니다.
- `trades`: `toUid` + `status`, `fromUid` + `status`
- `battles`: `status` + `createdAt(desc)`

## Storage 규칙 (Storage → 규칙) — 커뮤니티 사진 첨부용

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /post_images/{uid}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == uid
        && request.resource.size < 5 * 1024 * 1024   // 5MB 제한
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```
