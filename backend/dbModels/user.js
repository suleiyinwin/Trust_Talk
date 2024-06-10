import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    userId: { type: String, required: true, unique: true },
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    profileurl: { type: String, required: false },
  });
  

const User = mongoose.model('users', userSchema);

export default User;
