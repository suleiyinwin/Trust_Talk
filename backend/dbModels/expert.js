import mongoose from 'mongoose';

const expertSchema = new mongoose.Schema({
    expertId: { type: String, required: true, unique: true },
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    profileurl: { type: String, required: true },
    name: { type: String, required: true },
    specility: { type: String, required: true },
    isActive: { type: Boolean, required: true, default: false },
  });

const Expert = mongoose.model('experts', expertSchema);
export default Expert;