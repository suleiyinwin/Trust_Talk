import { Router } from 'express';
import signup from '../controllers/auth/signup.js';
import login from '../controllers/auth/login.js';
import expertlogin from '../controllers/auth/expertlogin.js';

const authRouter = Router();
authRouter.post('/signup',signup);
authRouter.post('/login',login);
authRouter.post('/expertlogin',expertlogin);

export default authRouter;