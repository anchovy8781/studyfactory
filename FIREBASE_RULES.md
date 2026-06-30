# Firebase 보안 규칙 (Firebase Console에 게시 필요)

앱에서 새로 추가된 기능(커뮤니티 신고·사진 첨부, 과목 성적 향상도 그래프)을
사용하려면 아래 규칙을 Firebase Console에 게시해야 합니다.

## Firestore 규칙 (Firestore Database → 규칙)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() { return request.auth != null; }

    // 사용자 문서 + 하위 컬렉션(pointHistory, grades)
    match /users/{uid} {
      allow read: if signedIn();
      allow write: if request.auth.uid == uid;

      match /pointHistory/{doc} {
        allow read, write: if request.auth.uid == uid;
      }
      // 과목 성적 향상도 그래프 (본인만)
      match /grades/{doc} {
        allow read, write: if request.auth.uid == uid;
      }
      // 연속 학습 기록 (본인만)
      match /studySessions/{doc} {
        allow read, write: if request.auth.uid == uid;
      }
    }

    // 커뮤니티 게시글 + 댓글
    match /posts/{postId} {
      allow read: if signedIn();
      allow create: if signedIn();
      // 좋아요/신고수/댓글수 갱신 허용
      allow update: if signedIn();
      allow delete: if request.auth.uid == resource.data.authorId;

      match /comments/{commentId} {
        allow read: if signedIn();
        allow create: if signedIn();
        allow delete: if request.auth.uid == resource.data.authorId;
      }
    }

    // 커뮤니티 신고
    match /reports/{reportId} {
      allow create: if signedIn();
      allow read, update, delete: if false; // 관리자 콘솔에서만 조회
    }

    // 이벤트 / 설정 (읽기 전용)
    match /events/{doc} { allow read: if true; }
    match /config/{doc} { allow read: if true; }

    // 월간 랭킹 결과 스냅샷 (읽기 전용, 쓰기는 Cloud Function만)
    match /rankingHistory/{doc} {
      allow read: if signedIn();
      allow write: if false;
    }

    // 탈퇴 기록
    match /withdrawals/{doc} {
      allow create: if signedIn();
      allow read: if false;
    }
  }
}
```

## Storage 규칙 (Storage → 규칙) — 커뮤니티 사진 첨부용

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 게시글 이미지: 본인 폴더에만 업로드, 읽기는 로그인 사용자 모두
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
