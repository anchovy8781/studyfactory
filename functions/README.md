# StudyVerse Cloud Functions

## 월간 랭킹 자동 보상 (`monthlyRankingReward`)

매월 1일 00:05 (한국 시간)에 자동 실행되어:

1. `users`를 `monthlyStudyMinutes`(이번 달 공부 시간) 내림차순으로 정렬
2. 순위 포인트 지급
   - **1위 ~ 10위 : 3000P**
   - **11위 ~ 50위 : 1000P**
   - 각 지급 시 `points` 증가 + `pointHistory` 기록
3. `rankingHistory/{YYYY-MM}`에 결과 스냅샷 저장
4. 모든 사용자의 `monthlyStudyMinutes`를 0으로 초기화(다음 달 시작)

> 앱은 공부 세션을 기록할 때 `monthlyStudyMinutes`를 누적합니다.
> 랭킹 화면(개인 랭킹)은 이 값으로 실시간 순위를 보여줍니다.

## 배포 방법

스케줄 함수는 **Blaze(종량제) 요금제**가 필요합니다.

```bash
# 1) Firebase CLI 설치 (최초 1회)
npm install -g firebase-tools

# 2) 로그인 & 프로젝트 선택
firebase login
firebase use studyfactory-3a14d

# 3) 의존성 설치
cd functions
npm install

# 4) 배포
firebase deploy --only functions
```

배포 후 Google Cloud Scheduler에 `monthlyRankingReward` 작업이 자동 등록됩니다.
즉시 테스트하려면 Cloud Console > Cloud Scheduler에서 해당 작업을 "지금 실행"
하거나, 함수 트리거를 수동 호출하세요.

## 참고

- 리전: `asia-northeast3` (서울)
- 단일 필드 색인(`monthlyStudyMinutes`)은 Firestore가 자동 생성하므로 별도
  복합 색인이 필요 없습니다.
