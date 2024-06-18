import { Router } from 'express';
import getExpertProfile from '../controllers/edu/getProfile.js';
import createContent from '../controllers/edu/createContent.js';
import expertContents from '../controllers/edu/getExpertContents.js';

const eduRouter = Router();
eduRouter.post('/getExpertProfile', getExpertProfile);
eduRouter.post('/createContent', createContent );
eduRouter.post('/expertContents',expertContents)

export default eduRouter;