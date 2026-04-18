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
    const assigneeEmail = newData.assignedToEmail;
    const title = newData.title || "New Task";

    let token = null;

    // First try: Document ID (for legacy/consistent IDs)
    const userDoc = await admin.firestore().collection("users").doc(assigneeId.toString()).get();
    if (userDoc.exists && userDoc.data().fcmToken) {
      token = userDoc.data().fcmToken;
    } else if (assigneeEmail) {
      // Second try: Email lookup (Highly reliable as email is unique)
      console.log(`ID lookup failed for ${assigneeId}. Trying email lookup: ${assigneeEmail}`);
      const userSnap = await admin.firestore()
        .collection("users")
        .where("email", "==", assigneeEmail.toLowerCase().trim())
        .limit(1)
        .get();
      
      if (!userSnap.empty) {
        token = userSnap.docs[0].data().fcmToken;
      }
    }

    if (!token) {
      console.log(`No token found for user ${assigneeId} / ${assigneeEmail}. Skipping notification.`);
      return null;
    }

    const message = {
      token: token,
      notification: {
        title: "New Task Assigned 📋",
        body: `You have been assigned: ${title}`,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK"
        }
      },
      apns: {
        payload: {
          aps: {
            contentAvailable: true,
            sound: "default"
          }
        }
      },
      data: {
        type: "task",
        taskId: context.params.taskId,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      }
    };

    try {
      await admin.messaging().send(message);
      console.log(`Notification sent to ${assigneeEmail || assigneeId}`);
    } catch (err) {
      console.error("FCM Error:", err);
    }
    return null;
  });

/**
 * Invite Notification & Account Setup Logic
 */
const sgMail = require("@sendgrid/mail");
const SENDGRID_KEY = process.env.SENDGRID_KEY || "";
const NGO_NAME = "Jayashree Foundation";
const FROM_EMAIL = "noreply@jayashreefoundation.org";

if (SENDGRID_KEY) {
  sgMail.setApiKey(SENDGRID_KEY);
}

exports.onUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    const email = data.email;
    const name = data.name;
    const role = data.role || "volunteer";

    if (!email) return;

    try {
      let actionLink;
      try {
        actionLink = await admin.auth().generatePasswordResetLink(email, {
          url: "https://jayashree-foundation07.web.app/login",
        });
      } catch (err) {
        actionLink = "https://jayashree-foundation07.web.app/login";
      }

      const msg = {
        to: email,
        from: { name: NGO_NAME, email: FROM_EMAIL },
        subject: `Welcome to ${NGO_NAME} — Set up your account`,
        html: `<h2>Welcome, ${name}!</h2><p>You have been added as <strong>${role}</strong>. <a href="${actionLink}">Click here to set your password.</a></p>`,
      };

      await sgMail.send(msg);
      await snap.ref.update({ inviteEmailSentAt: admin.firestore.FieldValue.serverTimestamp() });
    } catch (error) {
      console.error(`Invite fail: ${email}`, error);
    }
  });

exports.resendInvite = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Auth required");

  const email = data.email;
  if (!email) throw new functions.https.HttpsError("invalid-argument", "email required");

  const snap = await admin.firestore().collection("users").where("email", "==", email.toLowerCase()).limit(1).get();
  if (snap.empty) throw new functions.https.HttpsError("not-found", "User not found");
  
  const userDoc = snap.docs[0].data();
  let actionLink = await admin.auth().generatePasswordResetLink(email, {
    url: "https://jayashree-foundation07.web.app/login",
  });

  await sgMail.send({
    to: email,
    from: { name: NGO_NAME, email: FROM_EMAIL },
    subject: `Reminder: Set up your ${NGO_NAME} account`,
    html: `<p>Hello ${userDoc.name}, <a href="${actionLink}">Set up your account here</a>.</p>`,
  });

  return { success: true };
});
