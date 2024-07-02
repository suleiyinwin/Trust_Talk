import admin from 'firebase-admin';
import Expert from '../../dbModels/expert.js';
import dotenv from 'dotenv';

dotenv.config();

export const updateIsActive = async (req, res) => {
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

        const { isActive } = req.body;
        if (isActive === undefined) {
            return res.status(400).send({ message: 'isActive field missing' });
        }

        expert.isActive = isActive;
        await expert.save();

        res.send({ message: 'isActive updated successfully' });
    } catch (error) {
        console.error('Error updating isActive:', error);
        res.status(500).send({ message: 'Error updating isActive', error: error.message });
    }
}