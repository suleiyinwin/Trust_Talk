import { Router } from 'express';
import expertlist from '../controllers/chat/expertlist.js';

const chatRouter = Router();
chatRouter.get('/expertlist',expertlist);

export default chatRouter;