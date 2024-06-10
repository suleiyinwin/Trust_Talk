import { initializeApp } from 'firebase/app';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import admin from 'firebase-admin';
import User from '../../dbModels/user.js';
import firebaseClientConfig from '../../database/firebaseClientConfig.js';

const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const app = initializeApp(firebaseClientConfig);
        const auth = getAuth(app);

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ error: 'User not found' });
        }

        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        // console.log('User logged in:', userCredential.user);
        const idToken = await userCredential.user.getIdToken();

        // Verify the ID token using Firebase Admin SDK
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        if (decodedToken) {
            res.status(200).json({ token: idToken });
        } else {
            res.status(401).json({ error: 'Invalid credentials' });
        }
    } catch (error) {
        console.error('Error logging in user:', error.message);
        res.status(500).json({ error: 'Failed to log in user' });
    }
};

export default login;
