/**
 * StudyVerse Cloud Functions — monthly ranking rewards.
 *
 * On the 1st of every month (Asia/Seoul) this:
 *   1. Ranks users by `monthlyStudyMinutes` (descending).
 *   2. Pays out ranking rewards:
 *        - 1위 ~ 10위  : +3000 P
 *        - 11위 ~ 50위 : +1000 P
 *      Each payout increments `points` and appends a `pointHistory` entry.
 *   3. Saves a snapshot to `rankingHistory/{YYYY-MM}`.
 *   4. Resets every user's `monthlyStudyMinutes` to 0 for the new month.
 *
 * Deploy:  firebase deploy --only functions
 * (Requires the Blaze plan for scheduled functions.)
 */

const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const TOP_REWARD = 3000; // ranks 1–10
const MID_REWARD = 1000; // ranks 11–50

function rewardForRank(rank) {
  if (rank >= 1 && rank <= 10) return TOP_REWARD;
  if (rank >= 11 && rank <= 50) return MID_REWARD;
  return 0;
}

exports.monthlyRankingReward = onSchedule(
  {
    // 00:05 on the 1st of every month, Korea time.
    schedule: "5 0 1 * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
  },
  async () => {
    const now = new Date();
    // The month that just ended (we run on the 1st of the new month).
    const ended = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const periodKey = `${ended.getFullYear()}-${String(
      ended.getMonth() + 1
    ).padStart(2, "0")}`;

    logger.info(`Running monthly ranking reward for ${periodKey}`);

    // 1. Rank the top 50 by monthly study minutes.
    const snap = await db
      .collection("users")
      .orderBy("monthlyStudyMinutes", "desc")
      .limit(50)
      .get();

    const winners = [];
    let batch = db.batch();
    let ops = 0;

    let rank = 0;
    for (const doc of snap.docs) {
      const minutes = doc.get("monthlyStudyMinutes") || 0;
      if (minutes <= 0) break; // ignore users with no study this month
      rank += 1;
      const reward = rewardForRank(rank);
      if (reward <= 0) continue;

      const userRef = doc.ref;
      batch.update(userRef, {
        points: admin.firestore.FieldValue.increment(reward),
      });
      const histRef = userRef.collection("pointHistory").doc();
      batch.set(histRef, {
        amount: reward,
        reason: `${periodKey} 랭킹 ${rank}위 보상`,
        type: "earn",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      ops += 2;

      winners.push({
        uid: doc.id,
        rank,
        minutes,
        reward,
        nickname: doc.get("displayName") || doc.get("email") || "익명",
      });

      if (ops >= 400) {
        await batch.commit();
        batch = db.batch();
        ops = 0;
      }
    }
    if (ops > 0) await batch.commit();

    // 2. Save a snapshot of this month's results.
    await db.collection("rankingHistory").doc(periodKey).set({
      period: periodKey,
      winners,
      rewardedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Reset monthlyStudyMinutes for ALL users + leaderboard (new month).
    await resetMonthlyMinutes("users");
    await resetMonthlyMinutes("leaderboard");

    logger.info(
      `Monthly ranking reward done: ${winners.length} users rewarded.`
    );
  }
);

async function resetMonthlyMinutes(collection) {
  const pageSize = 400;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const page = await db
      .collection(collection)
      .where("monthlyStudyMinutes", ">", 0)
      .orderBy("monthlyStudyMinutes")
      .limit(pageSize)
      .get();
    if (page.empty) break;

    const batch = db.batch();
    for (const doc of page.docs) {
      batch.update(doc.ref, { monthlyStudyMinutes: 0 });
    }
    await batch.commit();
    // Committed docs are now 0, so the next query skips them automatically.
    if (page.size < pageSize) break;
  }
}
