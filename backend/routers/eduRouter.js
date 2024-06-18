import { Router } from 'express';
import getExpertProfile from '../controllers/edu/getProfile.js';
import createContent from '../controllers/edu/createContent.js';

const eduRouter = Router();
eduRouter.post('/getExpertProfile', getExpertProfile);
eduRouter.post('/createContent', createContent );

export default eduRouter;