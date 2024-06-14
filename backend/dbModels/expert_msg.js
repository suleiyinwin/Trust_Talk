import mongoose from "mongoose";

const messageSchema = new mongoose.Schema({
    msgId: { type: String, required: true, unique: true },
    chatId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'chats',
    },
    sender: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'experts',
    },
    receiver: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users',
    },
    content: { type: String,trim: true, required: true },
    read: { type: Boolean, required: true, default: false },
    readBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users',
    },
    },
    { timestamps: true }
);

const Message = mongoose.model('messages', messageSchema);
export default Message;