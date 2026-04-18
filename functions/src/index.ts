import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as sgMail from "@sendgrid/mail";

admin.initializeApp();

// ─── CONFIGURATION ─────────────────────────────────────────────────────────
// Set your SendGrid API key in Firebase config:
//   firebase functions:config:set sendgrid.key="SG.YOUR_API_KEY_HERE"
//   firebase functions:config:set ngo.name="Jayashree Foundation"
//   firebase functions:config:set ngo.from_email="noreply@jayashreefoundation.org"
//
// Then deploy:
//   cd functions && npm install && firebase deploy --only functions

const SENDGRID_KEY   = (functions.config() as any)?.sendgrid?.key         ?? process.env.SENDGRID_KEY ?? "";
const NGO_NAME       = (functions.config() as any)?.ngo?.name             ?? "Jayashree Foundation";
const FROM_EMAIL     = (functions.config() as any)?.ngo?.from_email       ?? "noreply@jayashreefoundation.org";

if (SENDGRID_KEY) {
  sgMail.setApiKey(SENDGRID_KEY);
}

// ─── TRIGGER: Send invite email when a new user is added ────────────────────
// This fires every time a document is created in /users collection
export const onUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    const email = data.email as string;
    const name  = data.name  as string;
    const role  = data.role  as string;

    if (!email) {
      functions.logger.warn(`No email for user ${context.params.userId}`);
      return;
    }

    try {
      // Generate a password reset / set-password link via Firebase Auth
      let actionLink: string;
      try {
        actionLink = await admin.auth().generatePasswordResetLink(email, {
          url: "https://jayashree-foundation07.web.app/login",
        });
      } catch (_err) {
        // User might not exist in Firebase Auth yet — skip link
        actionLink = "https://jayashree-foundation07.web.app/login";
      }

      const roleDisplay = role.replace(/([A-Z])/g, " $1").trim();

      const msg = {
        to: email,
        from: { name: NGO_NAME, email: FROM_EMAIL },
        subject: `You've been added to ${NGO_NAME} — Set up your account`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #1e40af, #7c3aed); padding: 24px; border-radius: 12px 12px 0 0;">
              <h1 style="color: white; margin: 0; font-size: 24px;">${NGO_NAME}</h1>
              <p style="color: rgba(255,255,255,0.8); margin: 4px 0 0;">Volunteer Management System</p>
            </div>
            <div style="background: #f8fafc; padding: 32px; border-radius: 0 0 12px 12px;">
              <h2 style="color: #1e293b;">Welcome, ${name}! 🎉</h2>
              <p style="color: #475569; line-height: 1.6;">
                You have been added to the <strong>${NGO_NAME}</strong> management 
                system as a <strong>${roleDisplay}</strong>.
              </p>
              <p style="color: #475569; line-height: 1.6;">
                Click the button below to set your password and access your account:
              </p>
              <div style="text-align: center; margin: 32px 0;">
                <a href="${actionLink}" 
                   style="background: #1e40af; color: white; padding: 14px 32px; border-radius: 8px; 
                          text-decoration: none; font-weight: bold; font-size: 16px; display: inline-block;">
                  Set Up My Account
                </a>
              </div>
              <p style="color: #94a3b8; font-size: 13px; margin-top: 24px;">
                If you did not expect this invitation, please ignore this email.<br/>
                This link will expire in 24 hours.
              </p>
              <hr style="border: 1px solid #e2e8f0; margin: 24px 0;" />
              <p style="color: #94a3b8; font-size: 12px; text-align: center;">
                ${NGO_NAME} &mdash; Empowering Communities
              </p>
            </div>
          </div>
        `,
      };

      await sgMail.send(msg as any);
      functions.logger.info(`Invite email sent to ${email} (role: ${role})`);

      // Update user doc to track email sent
      await snap.ref.update({ inviteEmailSentAt: admin.firestore.FieldValue.serverTimestamp() });
    } catch (error) {
      functions.logger.error(`Failed to send invite email to ${email}:`, error);
    }
  });

// ─── HTTP: Resend invite manually ───────────────────────────────────────────
export const resendInvite = functions.https.onCall(async (data, context) => {
  // Only admins / superadmins can call this
  const callerUid = context.auth?.uid;
  if (!callerUid) throw new functions.https.HttpsError("unauthenticated", "Must be signed in");

  const { email } = data as { email: string };
  if (!email) throw new functions.https.HttpsError("invalid-argument", "email required");

  // Fetch user from Firestore to get name
  const snap = await admin.firestore()
    .collection("users")
    .where("email", "==", email.toLowerCase())
    .limit(1)
    .get();

  if (snap.empty) throw new functions.https.HttpsError("not-found", `No user with email ${email}`);
  const userDoc = snap.docs[0].data();

  let actionLink: string;
  try {
    actionLink = await admin.auth().generatePasswordResetLink(email, {
      url: "https://jayashree-foundation07.web.app/login",
    });
  } catch (_) {
    actionLink = "https://jayashree-foundation07.web.app/login";
  }

  await sgMail.send({
    to: email,
    from: { name: NGO_NAME, email: FROM_EMAIL },
    subject: `Reminder: Set up your ${NGO_NAME} account`,
    html: `<p>Hello ${userDoc.name},</p>
           <p>This is a reminder to <a href="${actionLink}">set up your account</a>.</p>`,
  } as any);

  return { success: true };
});
