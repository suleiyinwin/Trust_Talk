import admin from 'firebase-admin';
import { bucket } from '../../database/firebaseConfig.js';
import dotenv from 'dotenv';
import firebaseClientConfig from '../../database/firebaseClientConfig.js';

dotenv.config();

export const signOutUser = async (req, res) => {
    try {
        const { idToken } = req.body;
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        await admin.auth().revokeRefreshTokens(userId);

        res.send({ message: 'User signed out successfully' });
    } catch (error) {
        res.status(500).send({ message: 'Error signing out', error: error.message });
    }
}