import dotenv from 'dotenv';

dotenv.config();

const serviceAccount = process.env.FIREBASE_PRIVATE_KEY_PATH;

export default serviceAccount;