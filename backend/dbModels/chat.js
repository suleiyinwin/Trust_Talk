import mongoose from "mongoose";

const chatSchema = new mongoose.Schema({
    chatId: { type: String, required: true, unique: true },
    messages: { type: Array, required: false },
    members: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'users',
        },
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'experts',
        },
    ],
    lastMessage: { type: mongoose.Schema.Types.ObjectId, ref: 'messages'},
    },
    { timestamps: true }
);

const Chat = mongoose.model('chats', chatSchema);
export default Chat;