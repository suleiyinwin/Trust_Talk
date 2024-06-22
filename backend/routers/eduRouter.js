import { Router } from 'express';
import getExpertProfile from '../controllers/edu/getProfile.js';
import createContent from '../controllers/edu/createContent.js';
import expertContents from '../controllers/edu/getExpertContents.js';
import getContentData from '../controllers/edu/getContentData.js';
import updateContentData from '../controllers/edu/updateContent.js';
import deleteContent from '../controllers/edu/deleteContent.js';
import getUser from '../controllers/edu/getUser.js';
import getUserContents from '../controllers/edu/getUserContents.js';

const eduRouter = Router();
eduRouter.post('/getExpertProfile', getExpertProfile);
eduRouter.post('/createContent', createContent );
eduRouter.post('/expertContents',expertContents);
eduRouter.post('/getContentData',getContentData);
eduRouter.post('/updateContent', updateContentData);
eduRouter.post('/deleteContent', deleteContent);
eduRouter.post('/getUser', getUser);
eduRouter.post('/userContents', getUserContents);

export default eduRouter;