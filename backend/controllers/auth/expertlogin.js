import { initializeApp } from 'firebase/app';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import admin from 'firebase-admin';
import firebaseClientConfig from '../../database/firebaseClientConfig.js';
import Expert from '../../dbModels/expert.js';

const expertlogin = async (req, res) => {
    try {
        const { email, password } = req.body;
        const app = initializeApp(firebaseClientConfig);
        const auth = getAuth(app);

        const expert = await Expert.findOne({ email });
        if (!expert) {
            return res.status(400).json({ message: 'Email does not exist' });
        }
        try {
            const userCredential = await signInWithEmailAndPassword(auth, email, password);
            const idToken = await userCredential.user.getIdToken();
            // Verify the ID token using Firebase Admin SDK
            const decodedToken = await admin.auth().verifyIdToken(idToken);
            if (decodedToken) {
                res.status(200).json({ token: idToken, expertId: expert.expertId });
            } else {
                console.error('Failed to verify ID token');
                res.status(401).json({ message: 'Invalid Email' });
            }
        }
        catch (firebaseError) {
            res.status(401).json({ message: 'Incorrect password' });
        }

    } catch (error) {
        console.error('Error logging in user:', error.message);
        res.status(500).json({ error: 'Failed to log in user' });
    }
};

export default expertlogin;
