import { Router } from 'express';
import expertlist from '../controllers/chat/expertlist.js';
import createChat from '../controllers/chat/createchat.js';

const chatRouter = Router();
chatRouter.get('/expertlist',expertlist);
chatRouter.post('/createchat', createChat);

export default chatRouter;