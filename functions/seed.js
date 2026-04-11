const admin = require("firebase-admin");

// Note: No serviceAccountKey required if you're logged in with Firebase CLI
admin.initializeApp({
  projectId: "project-08d246f1-d6d3-42e6-a40"
});

const db = admin.firestore();

async function seed() {
  console.log("Starting manual seed...");
  
  const users = [
    {id: 0, name: 'Vikram Bose',      email: 'vikram@hopeconnect.org',  password: 'vikram123',  role: 'superAdmin', avatar: 'VB'},
    {id: 3, name: 'Priya Sharma',     email: 'priya@hopeconnect.org',   password: 'priya123',   role: 'admin',      avatar: 'PS'},
    {id: 2, name: 'Dr. Anjali Mehta', email: 'anjali@hopeconnect.org',  password: 'anjali123',  role: 'member',     avatar: 'AM'},
    {id: 1, name: 'Rahul Verma',      email: 'rahul@hopeconnect.org',   password: 'rahul123',   role: 'volunteer',  avatar: 'RV'},
  ];

  const donations = [
    {donorName: "Ramesh Gupta", amount: 25000, date: "2025-03-20", status: "completed"},
    {donorName: "Anonymous", amount: 10000, date: "2025-03-25", status: "completed"}
  ];

  try {
    for (const u of users) {
      await db.collection("users").doc(u.id.toString()).set(u);
      console.log(`Added user: ${u.email}`);
    }
    
    for (const d of donations) {
      await db.collection("donations").add(d);
      console.log(`Added donation: ${d.donorName}`);
    }

    console.log("✅ Manual seed completed successfully!");
    process.exit(0);
  } catch (err) {
    console.error("❌ Seed failed:", err);
    process.exit(1);
  }
}

seed();
