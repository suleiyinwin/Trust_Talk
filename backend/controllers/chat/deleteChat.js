import Chat from "../../dbModels/chat.js";
import admin from 'firebase-admin';
import firebaseClientConfig from '../../database/firebaseClientConfig.js';
import dotenv from 'dotenv';

dotenv.config();


const deleteChat = async (req, res) => {
    try {
        const authorizationHeader = req.headers.authorization;
        if (!authorizationHeader || !authorizationHeader.startsWith('Bearer ')) {
            return res.status(401).send({ message: 'Authorization header missing or incorrect' });
        }

        const idToken = authorizationHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        const chatId = req.params.chatId;
        const chat = await Chat.findOne({ chatId: chatId });
        if (!chat) {
            return res.status(404).send({ message: 'Chat not found' });
        }

        if (!chat.members.includes(userId)) {
            return res.status(403).send({ message: 'Unauthorized' });
        }

        await chat.remove();
        res.status(200).send({ message: 'Chat and associated messages deleted' });
    } catch (error) {
        console.error('Error deleting chat:', error.message);
        res.status(500).json({ error: 'Failed to delete chat' });
    }
};

export default deleteChat;