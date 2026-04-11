const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");

admin.initializeApp();

/**
 * Razorpay Order Creator (V1)
 */
exports.createRazorpayOrder = functions.runWith({ 
  secrets: ["RAZORPAY_KEY_ID", "RAZORPAY_KEY_SECRET"] 
}).https.onCall(async (data, context) => {
  const amount = data.amount;
  const currency = data.currency || "INR";

  if (!amount || typeof amount !== "number" || amount < 1) {
    throw new functions.https.HttpsError("invalid-argument", "Amount must be a positive number.");
  }

  const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });

  try {
    const order = await razorpay.orders.create({
      amount: amount * 100,
      currency: currency,
      receipt: `rcpt_${Date.now()}`,
    });
    return { orderId: order.id, amount: order.amount, currency: order.currency };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message || "Razorpay error");
  }
});

/**
 * Notify Admins of New Donation (V1)
 */
exports.notifyAdminsOnDonation = functions.firestore
  .document("donations/{donationId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const donorName = data.donorName || "Anonymous";
    const amount = data.amount || 0;

    console.log(`Donation: ₹${amount} from ${donorName}`);

    const adminSnap = await admin.firestore()
      .collection("users")
      .where("role", "==", "admin")
      .get();

    const tokens = [];
    adminSnap.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) tokens.push(userData.fcmToken);
    });

    if (tokens.length === 0) {
      console.log("No admin tokens found. Skipping notification.");
      return null;
    }

    const message = {
      notification: {
        title: "New Donation Received! 🎉",
        body: `${donorName} just donated ₹${amount}.`,
      },
      data: {
        type: "donation",
        donationId: context.params.donationId,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      },
      tokens: tokens
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`Successfully sent ${response.successCount} notifications. Total attempted: ${tokens.length}`);
    } catch (err) {
      console.error("FCM Error:", err);
    }
    return null;
  });

/**
 * Notify Volunteer of New Task (V1)
 */
exports.notifyVolunteerOnTask = functions.firestore
  .document("tasks/{taskId}")
  .onWrite(async (change, context) => {
    const after = change.after;
    const before = change.before;

    if (!after.exists) return null;
    const newData = after.data();
    const oldData = before.exists ? before.data() : null;

    if (oldData && oldData.assignedToId === newData.assignedToId) return null;

    const assigneeId = newData.assignedToId;
    const title = newData.title || "New Task";

    const userDoc = await admin.firestore().collection("users").doc(assigneeId.toString()).get();
    const token = userDoc.exists ? userDoc.data().fcmToken : null;

    if (!token) {
      console.log(`No token found for volunteer ${assigneeId}. Skipping notification.`);
      return null;
    }

    const message = {
      token: token,
      notification: {
        title: "New Task Assigned 📋",
        body: `You have been assigned: ${title}`,
      },
      data: {
        type: "task",
        taskId: context.params.taskId,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      }
    };

    try {
      await admin.messaging().send(message);
      console.log(`Notification sent to volunteer ${assigneeId}`);
    } catch (err) {
      console.error("FCM Error:", err);
    }
    return null;
  });
