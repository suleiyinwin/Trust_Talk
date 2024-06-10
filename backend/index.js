import express from 'express';
const app = express();
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';
import connectDB from './database/connect.js';
import admin from 'firebase-admin';
import serviceAccount from './database/firebaseConfig.js';
import authRouter from './routers/authRouter.js';
import chatRouter from './routers/chatRouter.js';
import eduRouter from './routers/eduRouter.js';
import mapRouter from './routers/mapRouter.js';

dotenv.config();

app.use(cors());
app.use(bodyParser.json());

connectDB();

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

app.get('/', (req, res) => {
    res.send('Hello World');
});

app.use('/auth', authRouter);
app.use('/chat', chatRouter);
app.use('/edu', eduRouter);
app.use('/map', mapRouter);

const PORT = process.env.PORT;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});