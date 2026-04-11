const admin = require("firebase-admin");

// Initialize using Application Default Credentials
admin.initializeApp({
  projectId: "project-08d246f1-d6d3-42e6-a40"
});

async function addTestDonation() {
  console.log("Adding perfectly formatted test donation...");
  const db = admin.firestore();
  
  // Create a perfectly formatted document mimicking what the app does
  const donationId = Date.now().toString(); // e.g. "1689..."
  const dummyDonation = {
    id: Number(donationId),
    donorName: "Super Test Donor",
    amount: 99999,
    date: new Date().toISOString(),
    type: "online", // using the enum string
    receiptGenerated: false,
    purpose: "Testing Real World Notifications",
    is80G: true
  };

  try {
    await db.collection("donations").doc(donationId).set(dummyDonation);
    console.log("✅ Successfully added test donation. Document ID:", donationId);
    console.log("The Cloud Function should trigger immediately.");
    process.exit(0);
  } catch (error) {
    console.error("Error adding donation:", error);
    process.exit(1);
  }
}

addTestDonation();
