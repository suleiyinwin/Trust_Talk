import Message from '../../dbModels/message.js';

const getMessages = async (req, res) => {
    try {
        const { chatId } = req.params;
        const messages = await Message.find({ chatId }).sort({ createdAt: 1 });
        res.status(200).json(messages);
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: 'Failed to fetch messages' });
    }
}

export default getMessages;