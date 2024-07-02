import admin from 'firebase-admin';
import Expert from '../../dbModels/expert.js';
import dotenv from 'dotenv';

dotenv.config();

export const getExpertProfile = async (req, res) => {
    try {
        const authorizationHeader = req.headers.authorization;
        if (!authorizationHeader || !authorizationHeader.startsWith('Bearer ')) {
            return res.status(401).send({ message: 'Authorization header missing or incorrect' });
        }

        const idToken = authorizationHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const expertId = decodedToken.uid;

        const expert = await Expert.findOne({ expertId });
        if (!expert) {
            return res.status(404).send({ message: 'expert not found' });
        }

        res.send(expert);
    } catch (error) {
        console.error('Error fetching expert data:', error);
        res.status(500).send({ message: 'Error fetching expert data', error: error.message });
    }
};