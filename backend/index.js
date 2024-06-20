import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import { Server as SocketIOServer } from 'socket.io';
import http from 'http';
import connectDB from './database/connect.js';
import authRouter from './routers/authRouter.js';
import chatRouter from './routers/chatRouter.js';
import eduRouter from './routers/eduRouter.js';
import mapRouter from './routers/mapRouter.js';
import userRouter from './routers/userRouter.js';
import mongoose from 'mongoose';
import Message from './dbModels/user_msg.js';
import Chat from './dbModels/chat.js';

const app = express();
const server = http.createServer(app); // Create an HTTP server
const io = new SocketIOServer(server); // Attach socket.io to the server
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));

connectDB();

app.get('/', (req, res) => {
    res.send('Hello World');
});

app.use('/auth', authRouter);
app.use('/chat', chatRouter);
app.use('/edu', eduRouter);
app.use('/map', mapRouter);
app.use('/user', userRouter);

// Socket.io connection
io.on('connection', (socket) => {
    console.log('New client connected');

    socket.on('createRoom', (chatId) => {
      socket.join(chatId);
      console.log(`Socket ${socket.id} joined room ${chatId}`);
    });

    socket.on('sendMessage', async (data) => {
        try {
          const newMessage = new Message({
            msgId: new mongoose.Types.ObjectId(),
            chatId: data.chatId,
            sender: data.sender,
            receiver: data.receiver,
            content: data.content,
            createdAt: data.createdAt,
            read: false,
          });
    
          await newMessage.save();

          // Update the chat document with the ID of the new message
          await Chat.findOneAndUpdate(
            { chatId: data.chatId },
            { lastMessage: newMessage._id },
            { new: true }
          );
    
        // Emit the message to all connected clients (including the sender)
        // io.emit('message', newMessage);

          // Emit the message to only targeted receiver
          io.to(data.chatId).emit('recieve message', newMessage);
          console.log('Message sent:', newMessage['content']);
        } catch (error) {
          console.error('Error saving message to MongoDB:', error);
        }
    });
    
    socket.on('disconnect', () => {
    console.log('A user disconnected');
    });
});

const PORT = process.env.PORT;
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
