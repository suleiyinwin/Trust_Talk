import Chat from "../../dbModels/chat.js";
import admin from 'firebase-admin';
import firebaseClientConfig from '../../database/firebaseClientConfig.js';
import dotenv from 'dotenv';
import { v4 as uuidv4 } from 'uuid';

dotenv.config();

const createChat = async (req, res) => {
    
    try {
        const { expertId, token } = req.body;
        const decodedToken = await admin.auth().verifyIdToken(token);
        const userId = decodedToken.uid;
        const chatId = uuidv4(); // Generate unique chatId

        const newChat = new Chat({
            chatId,
            members: [userId, expertId],
        });
        await newChat.save();
        // Emit the new chat event to all connected clients
        // io.emit('chatCreated', newChat);

        res.status(201).json(newChat);
    } catch (error) {
        console.error('Error creating chat:', error.message);
        res.status(500).json({ error: 'Failed to create chat' });
    }
}

export default createChat;