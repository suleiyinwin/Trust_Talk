import { Router } from 'express';
import { updateUserProfile, getUserProfile, signOutUser, changePassword, deleteAccount } from '../controllers/userManagement/userEdit.js';

const userRouter = Router();

// Route to update user profile
userRouter.post('/updateProfile', updateUserProfile);

// Route to view user profile
userRouter.get('/getUserProfile', getUserProfile);

//Route to sign out
userRouter.post('/signOut',signOutUser);

//Change password
userRouter.post('/changePassword', changePassword);

//Delete Account
userRouter.delete('/deleteAccount', deleteAccount);
export default userRouter;
