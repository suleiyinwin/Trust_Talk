import multer from 'multer';
import { v4 as uuidv4 } from 'uuid';
import admin from 'firebase-admin';
import User from '../../dbModels/user.js';

// multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

const bucket = admin.storage().bucket();

// Update user profile
const updateProfile = (req, res) => {
    try {
        const { userId, username, email } = req.body;
        let profileurl = '';

        if (req.file) {
            const blob = bucket.file(`profile_images/${uuidv4()}`);
            const blobStream = blob.createWriteStream({
                metadata: {
                    contentType: req.file.mimetype
                }
            });

            blobStream.on('error', (err) => {
                res.status(500).send({ message: 'Error uploading image', error: err.message });
            });

            blobStream.on('finish', async () => {
                profileurl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
                await updateUser(userId, username, email, profileurl, res);
            });
            blobStream.end(req.file.buffer);
        } else {
            updateUser(userId, username, email, profileurl, res);
        }
    } catch (error) {
        res.status(500).send({ message: 'Error updating profile', error: error.message });
    }
};

const updateUser = async (userId, username, email, profileurl, res) => {
    try {
        const update = { username, email };
        if (profileurl) {
            update.profileurl = profileurl;
        }
        const user = await User.findOneAndUpdate({ userId }, update, { new: true });
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }
        res.send({ message: 'Profile updated successfully', user });
    } catch (error) {
        res.status(500).send({ message: 'Error updating user', error: error.message });
    }
};

// Get user profile
const getUserProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const user = await User.findOne({ userId });

        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        res.send(user);
    } catch (error) {
        res.status(500).send({ message: 'Error fetching user', error: error.message });
    }
};

export { updateProfile, getUserProfile, upload };
