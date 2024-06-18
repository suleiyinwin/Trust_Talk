import express from 'express';
const app = express();
import bodyParser from 'body-parser';
import cors from 'cors';
import connectDB from './database/connect.js';
import authRouter from './routers/authRouter.js';
import chatRouter from './routers/chatRouter.js';
import eduRouter from './routers/eduRouter.js';
import mapRouter from './routers/mapRouter.js';
import userRouter from './routers/userRouter.js';

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

const PORT = process.env.PORT;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
