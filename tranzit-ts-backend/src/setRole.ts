import admin from "firebase-admin";

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

async function setRoleByPhoneNumber(phoneNumber: string, role: string) {
  const user = await admin.auth().getUserByPhoneNumber(phoneNumber);
  await admin.auth().setCustomUserClaims(user.uid, { role });
  console.log(`✅ Role "${role}" set for user ${phoneNumber}`);
}

setRoleByPhoneNumber("+917488373111", "admin")
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
