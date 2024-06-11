import { Router } from "express";
import {updateProfile, getUserProfile, upload} from '../controllers/userManagement/userEdit.js'

const userRouter = Router();
userRouter.post('/updateProfile', upload.single('profileImage'), updateProfile);
userRouter.get('/user/:userId', getUserProfile);

export default userRouter;