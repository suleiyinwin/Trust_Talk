import Message from "../../dbModels/message.js";

export const markRead = async (req, res) => {
    try {
        const { messageId } = req.params;
        await Message.findOneAndUpdate({msgId: messageId}, { read: true }, { new: true });
        res.status(200).send({ success: true, message: 'Message marked as read' });
    } catch (error) {
        console.error('Failed to mark message as read:', error);
        res.status(500).send({ success: false, message: 'Failed to mark message as read' });
    }
};