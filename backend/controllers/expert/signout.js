import admin from 'firebase-admin';
import dotenv from 'dotenv';

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