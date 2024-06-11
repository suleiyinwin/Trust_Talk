import { Router } from 'express';
import { updateUserProfile, getUserProfile } from '../controllers/userManagement/userEdit.js';

const userRouter = Router();

// Route to update user profile
userRouter.post('/updateProfile', updateUserProfile);

// Route to view user profile
userRouter.get('/getUserProfile', getUserProfile);

export default userRouter;
