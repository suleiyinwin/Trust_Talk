import mongoose from "mongoose";
import Message from "./message.js";

const chatSchema = new mongoose.Schema({
    chatId: { type: String, required: true, unique: true },
    members: { type: Array, required: true },
    lastMessage: { type: mongoose.Schema.Types.ObjectId, ref: 'messages'},
    },
    { timestamps: true }
);

chatSchema.pre('remove', async function(next) {
    try {
        await Message.deleteMany({ chatId: this.chatId });
        next();
    } catch (err) {
        next(err);
    }
});

const Chat = mongoose.model('chats', chatSchema);
export default Chat;