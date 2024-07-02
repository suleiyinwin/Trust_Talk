import Chat from "../../dbModels/chat.js";
import Message from "../../dbModels/message.js";
import admin from 'firebase-admin';
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

        // Delete the associated messages
        await Message.deleteMany({ chatId });
        // Delete the chat
        await Chat.deleteOne({ chatId });

        res.status(200).send({ message: 'Chat and associated messages deleted' });
    } catch (error) {
        console.error('Error deleting chat:', error.message);
        res.status(500).json({ error: 'Failed to delete chat' });
    }
};

export default deleteChat;