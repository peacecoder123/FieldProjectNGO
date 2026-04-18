import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
const Razorpay = require("razorpay");

admin.initializeApp();

const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID ?? "";
const RAZORPAY_SECRET = process.env.RAZORPAY_SECRET ?? "";

// Trigger: When a user doc is created in Firestore, ensure a Firebase Auth
// account exists for them so they can sign in with Google.
export const onUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    const email = data.email as string;
    const name  = data.name  as string;

    if (!email) return;

    try {
      // Ensure the user has a Firebase Auth record so Google Sign-In works
      await admin.auth().getUserByEmail(email);
    } catch (err: any) {
      if (err.code === "auth/user-not-found") {
        try {
          await admin.auth().createUser({
            email: email,
            displayName: name,
            emailVerified: false,
          });
          functions.logger.info(`Auth account created for: ${email}`);
        } catch (createErr) {
          functions.logger.error("Failed to create auth user:", createErr);
        }
      } else {
        functions.logger.error("Error checking auth user:", err);
      }
    }

    // Mark the invite timestamp
    await snap.ref.update({
      inviteEmailSentAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

// Razorpay: Create Payment Order
export const createRazorpayOrder = functions.https.onCall(async (data, context) => {
  const { amount, currency } = data as { amount: number; currency: string };

  if (!RAZORPAY_KEY_ID || !RAZORPAY_SECRET) {
    throw new functions.https.HttpsError("failed-precondition", "API Keys missing.");
  }

  const rzp = new (Razorpay as any)({
    key_id: RAZORPAY_KEY_ID,
    key_secret: RAZORPAY_SECRET,
  });

  try {
    const options = {
      amount: amount * 100, // paise
      currency: currency || "INR",
      receipt: `receipt_${Date.now()}`,
    };
    const order = await rzp.orders.create(options);
    return { orderId: order.id };
  } catch (error) {
    functions.logger.error("Razorpay error:", error);
    throw new functions.https.HttpsError("internal", "Failed to create order.");
  }
});
