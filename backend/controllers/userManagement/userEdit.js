import admin from 'firebase-admin';
import User from '../../dbModels/user.js';
import { bucket } from '../../database/firebaseConfig.js';
import { v4 as uuidv4 } from 'uuid';
import multer from 'multer';

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

export const signOutUser = async (req,res) => {
    try{
        const {idToken} = req.body;
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        await admin.auth().revokeRefreshTokens(userId);

        res.send({message : 'User signed out successfully'});
    }catch (error){
        res.status(500).send({message: 'Error signing out', error: error.message});
    }
}
