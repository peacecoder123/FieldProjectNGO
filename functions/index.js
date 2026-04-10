const functions = require("firebase-functions");
const Razorpay = require("razorpay");

/**
 * Creates a Razorpay Order on the server side and returns the order_id.
 * Uses Firebase Functions V1 to avoid Google Cloud Run IAM "unauthenticated" errors.
 */
exports.createRazorpayOrder = functions.runWith({ 
  secrets: ["RAZORPAY_KEY_ID", "RAZORPAY_KEY_SECRET"] 
}).https.onCall(async (data, context) => {
  const amount = data.amount;
  const currency = data.currency || "INR";

  console.log("Received order request:", { amount, currency });

  if (!amount || typeof amount !== "number" || amount < 1) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Amount must be a positive number (in rupees)."
    );
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

    console.log("Order created successfully:", order.id);

    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
    };
  } catch (error) {
    console.error("Razorpay order creation failed:", JSON.stringify(error));
    throw new functions.https.HttpsError(
      "internal",
      "Failed to create payment order: " + (error.message || String(error))
    );
  }
});
