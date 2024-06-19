import { Router } from 'express';
import expertlist from '../controllers/chat/expertlist.js';
import createChat from '../controllers/chat/createchat.js';
import expertinfo from '../controllers/chat/expertinfo.js';
import chatlist from '../controllers/chat/chatlist.js';
import getMessages from '../controllers/chat/getMessages.js';

const chatRouter = Router();
chatRouter.get('/expertlist',expertlist);
chatRouter.post('/createchat', createChat);
chatRouter.get('/expertinfo/:id', expertinfo);
chatRouter.get('/chatlist', chatlist);
chatRouter.get('/messages/:chatId', getMessages);

export default chatRouter;