import dotenv from 'dotenv';

dotenv.config();

const googleMapsConfig = {
    apiKey: process.env.GOOGLE_PLACES_API_KEY,
};

export default googleMapsConfig;
