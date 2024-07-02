import Chat from "../../dbModels/chat.js";
import admin from 'firebase-admin';

const chatlist = async (req, res) => {
    try {
        const authorizationHeader = req.headers.authorization;
        if (!authorizationHeader || !authorizationHeader.startsWith('Bearer ')) {
            return res.status(401).send({ message: 'Authorization header missing or incorrect' });
        }

        const idToken = authorizationHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        const chats = await Chat.find({ members : userId }).populate('lastMessage');
        res.status(200).json(chats);
    } catch (error) {
        console.error('Error fetching chats:', error.message);
        res.status(500).json({ error: 'Failed to fetch chats' });
    }
}

export default chatlist;