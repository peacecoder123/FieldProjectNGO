const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");

admin.initializeApp();

/**
 * Razorpay Order Creator (V1)
 * 
 * Keys are loaded from functions/.env file automatically by Firebase.
 */
exports.createRazorpayOrder = functions.https.onCall(async (data, context) => {
  const keyId = process.env.RAZORPAY_KEY_ID;
  const keySecret = process.env.RAZORPAY_KEY_SECRET;

  // ── Validate API keys exist ──────────────────────────────────────────────
  if (!keyId || !keySecret) {
    console.error("RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET not set in .env");
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Payment service is not configured. Please contact support."
    );
  }

  const amount = data.amount;
  const currency = data.currency || "INR";

  if (!amount || typeof amount !== "number" || amount < 1) {
    throw new functions.https.HttpsError("invalid-argument", "Amount must be a positive number.");
  }

  const razorpay = new Razorpay({
    key_id: keyId,
    key_secret: keySecret,
  });

  try {
    const order = await razorpay.orders.create({
      amount: amount * 100,
      currency: currency,
      receipt: `rcpt_${Date.now()}`,
    });
    return { orderId: order.id, amount: order.amount, currency: order.currency };
  } catch (error) {
    console.error("Razorpay order creation failed:", error);
    throw new functions.https.HttpsError("internal", error.message || "Razorpay error");
  }
});

/**
 * Helper to get all Admin/SuperAdmin tokens
 */
async function getAdminTokens() {
  const adminSnap = await admin.firestore()
    .collection("users")
    .where("role", "in", ["admin", "superAdmin"])
    .get();

  const tokens = [];
  adminSnap.forEach(doc => {
    const userData = doc.data();
    if (userData.fcmToken) tokens.push(userData.fcmToken);
  });
  return tokens;
}

/**
 * Helper to send multicast notification to multiple tokens
 */
async function sendToTokens(tokens, title, body, data = {}) {
  if (!tokens || tokens.length === 0) {
    console.log("No tokens provided for notification.");
    return;
  }
  const message = {
    notification: { title, body },
    data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
    tokens: tokens
  };
  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`Sent ${response.successCount} notifications successfully.`);
  } catch (err) {
    console.error("FCM Multicast Error:", err);
  }
}

/**
 * Helper to send notification to a single token
 */
async function sendToToken(token, title, body, data = {}) {
  if (!token) return;
  const message = {
    token: token,
    notification: { title, body },
    android: {
      priority: "high",
      notification: {
        channelId: "high_importance_channel",
        clickAction: "FLUTTER_NOTIFICATION_CLICK"
      }
    },
    data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" }
  };
  try {
    await admin.messaging().send(message);
    console.log(`Notification sent to single token.`);
  } catch (err) {
    console.error("FCM Single Error:", err);
  }
}

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
    const tokens = await getAdminTokens();
    await sendToTokens(
      tokens,
      "New Donation Received! 🎉",
      `${donorName} just donated ₹${amount}.`,
      { type: "donation", donationId: context.params.donationId }
    );
    return null;
  });

/**
 * Task Notification Logic (V1)
 */
exports.notifyTaskEvents = functions.firestore
  .document("tasks/{taskId}")
  .onWrite(async (change, context) => {
    const after = change.after;
    const before = change.before;

    if (!after.exists) return null; // Deletion

    const newData = after.data();
    const oldData = before.exists ? before.data() : null;
    const taskId = context.params.taskId;

    // --- Scenario 1: New Task Assigned OR Assignee Changed ---
    if (!oldData || (oldData.assignedToId !== newData.assignedToId)) {
        const assigneeId = newData.assignedToId;
        const assigneeEmail = newData.assignedToEmail;
        const title = newData.title || "New Task";

        let token = null;
        const userDoc = await admin.firestore().collection("users").doc(assigneeId.toString()).get();
        if (userDoc.exists && userDoc.data().fcmToken) {
            token = userDoc.data().fcmToken;
        } else if (assigneeEmail) {
            const userSnap = await admin.firestore().collection("users").where("email", "==", assigneeEmail.toLowerCase().trim()).limit(1).get();
            if (!userSnap.empty) token = userSnap.docs[0].data().fcmToken;
        }

        if (token) {
            await sendToToken(token, "New Task Assigned 📋", `You have been assigned: ${title}`, { type: "task", taskId });
        }
    }

    // --- Scenario 2: Task Submitted (Notify Admins) ---
    if (oldData && oldData.status !== "submitted" && newData.status === "submitted") {
        const tokens = await getAdminTokens();
        await sendToTokens(tokens, "Task Submitted 📤", `${newData.assignedToName} has submitted task: ${newData.title}`, { type: "task", taskId });
    }

    // --- Scenario 3: Task Approved/Rejected (Notify Volunteer) ---
    if (oldData && oldData.status !== newData.status && (newData.status === "approved" || newData.status === "rejected")) {
        const assigneeId = newData.assignedToId;
        const userDoc = await admin.firestore().collection("users").doc(assigneeId.toString()).get();
        if (userDoc.exists && userDoc.data().fcmToken) {
            const title = newData.status === "approved" ? "Task Approved ✅" : "Task Rejected ❌";
            const body = newData.status === "approved" 
                ? `Your submission for "${newData.title}" has been approved!`
                : `Your submission for "${newData.title}" was rejected. Please check details.`;
            await sendToToken(userDoc.data().fcmToken, title, body, { type: "task", taskId });
        }
    }

    return null;
  });

/**
 * Helper to notify Admins about new Requests
 */
async function notifyAdminsOnNewRequest(type, title, requesterName, id) {
  const tokens = await getAdminTokens();
  await sendToTokens(tokens, `New ${type} Request 📄`, `${requesterName} submitted a new ${type} request: ${title}`, { type: type.toLowerCase(), requestId: id });
}

/**
 * Helper to notify User about Request Status Change
 */
async function notifyUserOnRequestUpdate(requesterId, type, title, status, id) {
    if (!requesterId) return;
    const userDoc = await admin.firestore().collection("users").doc(requesterId).get();
    if (userDoc.exists && userDoc.data().fcmToken) {
        const mainTitle = status === "approved" ? "Request Approved ✅" : (status === "rejected" ? "Request Rejected ❌" : "Request Update 📄");
        const body = `Your ${type} request "${title}" is now ${status}.`;
        await sendToToken(userDoc.data().fcmToken, mainTitle, body, { type: type.toLowerCase(), requestId: id });
    }
}

// triggers for Requests
exports.onGeneralRequestWrite = functions.firestore.document("general_requests/{id}").onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after) return null;
    if (!before) {
        await notifyAdminsOnNewRequest("General", after.requestType, after.requesterName, context.params.id);
    } else if (before.status !== after.status) {
        await notifyUserOnRequestUpdate(after.requesterId, "General", after.requestType, after.status, context.params.id);
    }
    return null;
});

exports.onMouRequestWrite = functions.firestore.document("mou_requests/{id}").onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after) return null;
    if (!before) {
        await notifyAdminsOnNewRequest("MOU", after.patientName, after.requesterName, context.params.id);
    } else if (before.status !== after.status) {
        await notifyUserOnRequestUpdate(after.requesterId, "MOU", after.patientName, after.status, context.params.id);
    }
    return null;
});

exports.onJoiningLetterWrite = functions.firestore.document("joining_letter_requests/{id}").onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after) return null;
    if (!before) {
        await notifyAdminsOnNewRequest("Joining Letter", after.name, after.name, context.params.id);
    } else if (before.status !== after.status) {
        await notifyUserOnRequestUpdate(after.requesterId, "Joining Letter", "Request", after.status, context.params.id);
    }
    return null;
});

exports.onDocumentRequestWrite = functions.firestore.document("document_requests/{id}").onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    if (!after) return null;
    if (!before) {
        await notifyAdminsOnNewRequest("Document", after.documentType, after.userName, context.params.id);
    } else if (before.status !== after.status) {
        await notifyUserOnRequestUpdate(after.userId, "Document", after.documentType, after.status, context.params.id);
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
