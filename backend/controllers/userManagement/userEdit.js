import admin from 'firebase-admin';
import User from '../../dbModels/user.js';
import { bucket } from '../../database/firebaseConfig.js';
import { v4 as uuidv4 } from 'uuid';
import multer from 'multer';
import dotenv from 'dotenv';
import axios from 'axios';
import firebaseClientConfig from '../../database/firebaseClientConfig.js';
import Chat from '../../dbModels/chat.js'
import Message from '../../dbModels/message.js';

dotenv.config();
// Multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({ storage: storage }).single('file');

export const updateUserProfile = async (req, res) => {
    upload(req, res, async (err) => {
        if (err) {
            return res.status(500).send({ message: 'Error uploading file', error: err.message });
        }

        try {
            const { idToken, username } = req.body;
            const decodedToken = await admin.auth().verifyIdToken(idToken);
            const userId = decodedToken.uid;

            let profileUrl = '';

            // Check if a new profile photo is uploaded
            if (req.file) {
                const blob = bucket.file(`profile_images/${uuidv4()}`);
                const blobStream = blob.createWriteStream({
                    metadata: {
                        contentType: req.file.mimetype,
                    },
                });

                blobStream.on('error', (err) => {
                    return res.status(500).send({ message: 'Error uploading image', error: err.message });
                });

                blobStream.on('finish', async () => {
                    profileUrl = `https://storage.googleapis.com/${bucket.name}/${blob.name}`;
                    console.log('Profile URL:', profileUrl);
                    await blob.makePublic();
                    await updateUser(userId, username, profileUrl, res);
                });

                blobStream.end(req.file.buffer);
            } else {
                // If no profile photo uploaded, only update username
                await updateUser(userId, username, profileUrl, res);
            }
        } catch (error) {
            res.status(500).send({ message: 'Error updating profile', error: error.message });
        }
    });
};

const updateUser = async (userId, username, profileUrl, res) => {
    try {
        // Check if the new username is already taken
        const existingUser = await User.findOne({ username });
        if (existingUser && existingUser.userId !== userId) {
            return res.status(400).json({ message: 'Username already exists' });
        }

        // Update user profile
        const update = {};
        if (username) {
            update.username = username;
        }
        if (profileUrl) {
            update.profileurl = profileUrl;
        }

        const user = await User.findOneAndUpdate({ userId }, update, { new: true });
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        console.log('User updated:', user); // Debugging log

        res.send({ message: 'Profile updated successfully', user });
    } catch (error) {
        res.status(500).send({ message: 'Error updating user', error: error.message });
    }
};

export const getUserProfile = async (req, res) => {
    try {
        const authorizationHeader = req.headers.authorization;
        if (!authorizationHeader || !authorizationHeader.startsWith('Bearer ')) {
            return res.status(401).send({ message: 'Authorization header missing or incorrect' });
        }

        const idToken = authorizationHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        const user = await User.findOne({ userId });
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }

        res.send(user);
    } catch (error) {
        console.error('Error fetching user data:', error);
        res.status(500).send({ message: 'Error fetching user data', error: error.message });
    }
};

export const signOutUser = async (req, res) => {
    try {
        const { idToken } = req.body;
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        await admin.auth().revokeRefreshTokens(userId);

        res.send({ message: 'User signed out successfully' });
    } catch (error) {
        res.status(500).send({ message: 'Error signing out', error: error.message });
    }
}

export const changePassword = async (req, res) => {
    const { idToken, currentPassword, newPassword } = req.body;

    try {
        // Verify ID token and get user ID
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        // Fetch user from Firebase Auth
        const user = await admin.auth().getUser(userId);

        // Verify the current password using Firebase Auth REST API
        const verifyPasswordUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${firebaseClientConfig.apiKey}`;
        
        let verifyPasswordResponse;
        try {
            verifyPasswordResponse = await axios.post(verifyPasswordUrl, {
                email: user.email,
                password: currentPassword,
                returnSecureToken: true,
            });
        } catch (verificationError) {
            console.error('Password verification error:', verificationError.response ? verificationError.response.data : verificationError.message);
            return res.status(400).send({ message: 'Wrong current password. Try again.' });
        }

        if (verifyPasswordResponse.data && verifyPasswordResponse.data.idToken) {
            // Change the password
            await admin.auth().updateUser(userId, { password: newPassword });
            res.send({ message: 'Password updated successfully' });
        } else {
            return res.status(400).send({ message: 'Wrong current password. Try again.' });
        }
    } catch (error) {
        console.error('Error changing password:', error);
        res.status(500).send({ message: 'Error changing password', error: error.message });
    }
};

export const deleteAccount = async (req, res) => {
    try {
        // Get the authorization header and verify the token
        const authorizationHeader = req.headers.authorization;
        if (!authorizationHeader || !authorizationHeader.startsWith('Bearer ')) {
            return res.status(401).send({ message: 'Authorization header missing or incorrect' });
        }

        const idToken = authorizationHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        // Delete user from Firebase Authentication
        await admin.auth().deleteUser(userId);

        // Delete user data from database
        const user = await User.findOneAndDelete({ userId });
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }
        // Find all chats involving the user
        const chats = await Chat.find({ members: userId });
        if (!chats || !Array.isArray(chats)) {
            throw new Error('chats is not iterable or not an array');
        }

        // Delete associated messages and chats
        for (const chat of chats) {
            // Delete the associated messages
            await Message.deleteMany({ chatId: chat.chatId });

            // Delete the chat
            await Chat.deleteOne({ chatId: chat.chatId });
        }

        res.send({ message: 'User account deleted successfully' });
    } catch (error) {
        console.error('Error deleting user account:', error);
        res.status(500).send({ message: 'Error deleting user account', error: error.message });
    }
};