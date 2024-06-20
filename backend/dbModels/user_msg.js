import mongoose from "mongoose";

const messageSchema = new mongoose.Schema({
    msgId: { type: String, required: true, unique: true },
    chatId: { type: String, required: true, trim: true },
    sender: { type: String, required: true, trim: true },
    receiver: { type: String, required: true, trim: true },
    content: { type: String, required: true, trim: true},
    createdAt: { type: String, required: true},
    read: { type: Boolean, required: true, default: false },
    readBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'experts',
    },
    },
);

const Message = mongoose.model('messages', messageSchema);
export default Message;