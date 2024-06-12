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

const app = express();
const server = http.createServer(app); // Create an HTTP server
const io = new SocketIOServer(server); // Attach socket.io to the server
app.use(cors());
app.use(bodyParser.json());

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

    // socket.on('disconnect', () => {
    //     console.log('Client disconnected');
    // });

    // // Example event handling
    // socket.on('example_event', (data) => {
    //     console.log('Received data:', data);
    //     // Emit an event to the client
    //     socket.emit('response_event', { message: 'Data received' });
    // });
});

const PORT = process.env.PORT;
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
