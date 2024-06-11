import dotenv from 'dotenv';
import admin from 'firebase-admin';

dotenv.config();

const serviceAccount = process.env.FIREBASE_PRIVATE_KEY_PATH;
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});
const bucket = admin.storage().bucket();
const db = admin.firestore();
const auth = admin.auth();

export { bucket,db,auth };