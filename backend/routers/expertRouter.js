import { Router } from 'express';
import { getExpertProfile } from '../controllers/expert/getExpert.js';
import { signOutUser } from '../controllers/expert/signout.js';
import { updateIsActive } from '../controllers/expert/updateActive.js';

const expertRouter = Router();

expertRouter.get('/getExpertProfile', getExpertProfile);
expertRouter.post('/signout', signOutUser);
expertRouter.post('/updateIsActive', updateIsActive);

export default expertRouter;