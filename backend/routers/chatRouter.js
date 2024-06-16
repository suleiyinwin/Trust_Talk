import { Router } from 'express';
import expertlist from '../controllers/chat/expertlist.js';
import createChat from '../controllers/chat/createchat.js';
import expertinfo from '../controllers/chat/expertinfo.js';

const chatRouter = Router();
chatRouter.get('/expertlist',expertlist);
chatRouter.post('/createchat', createChat);
chatRouter.get('/expertinfo/:id', expertinfo);

export default chatRouter;