const admin = require('firebase-admin');
const path = require('path');

let serviceAccount;

// Check if Firebase Key is provided via Environment Variable (for Cloud)
if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
  } catch (e) {
    console.error('❌ Failed to parse FIREBASE_SERVICE_ACCOUNT_KEY from env:', e.message);
  }
} 

// Fallback to local file if no env variable or failed to parse
if (!serviceAccount) {
  try {
    serviceAccount = require('./serviceAccountKey.json');
  } catch (error) {
    console.error('❌ Could not find or load serviceAccountKey.json locally.');
  }
}

try {
  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('🔥 Firebase Admin SDK initialized');
  } else {
    console.error('❌ Firebase Admin SDK NOT initialized: No credentials found.');
  }
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin SDK:', error);
}

const sendPush = async (token, title, body, data = {}) => {
  const message = {
    notification: {
      title: title,
      body: body
    },
    data: {
      ...data,
      click_action: 'FLUTTER_NOTIFICATION_CLICK'
    },
    token: token
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('✅ FCM Successfully sent message:', response);
    return { success: true, response };
  } catch (error) {
    console.error('❌ FCM Error sending message:', error);
    return { success: false, error };
  }
};

module.exports = { admin, sendPush };
