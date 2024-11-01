const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.scheduledFunction = functions.pubsub
    .schedule("0 0 * * *")
    .timeZone("Asia/Riyadh")
    .onRun(async (context) => {
      const db = admin.firestore();
      const now = admin.firestore.Timestamp.now();
      const expiredRequests = db.collection("investment_requests")
          .where("validUntil", "<", now)
          .where("status", "==", "pending");

      try {
        const snapshot = await expiredRequests.get();
        const batch = db.batch();

        snapshot.forEach((doc) => {
          batch.update(doc.ref, {status: "expired"});
        });

        await batch.commit();
        console.log("Expired requests updated successfully.");
      } catch (error) {
        console.error("Error updating expired requests:", error);
      }
    });
