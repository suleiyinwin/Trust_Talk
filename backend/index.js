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
        console.log('createRoom', chatId);
    });

    socket.on('sendMessage', async (data) => {
        try {
          const newMessage = new Message({
            msgId: new mongoose.Types.ObjectId(),
            chatId: data.chatId,
            sender: data.senderId,
            receiver: data.receiverId,
            content: data.message,
            read: false,
          });
    
          await newMessage.save();
    
          // Emit the message to all connected clients (including the sender)
          io.emit('message', newMessage);
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
