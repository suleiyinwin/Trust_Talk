// File: src/routes/mapRouter.js
import { Router } from 'express';
import { getNearbyPlaces, getPlaceDetails } from '../controllers/map/placesInfo.js';

const mapRouter = Router();

mapRouter.post('/getNearbyPlaces', async (req, res) => {
  const { latitude, longitude, type, keyword } = req.body;
  try {
    const places = await getNearbyPlaces(latitude, longitude, type, keyword);
    const detailedPlaces = await Promise.all(
      places.map(async (place) => {
        const details = await getPlaceDetails(place.place_id);
        return { ...place, ...details };
      })
    );
    res.json(detailedPlaces);
  } catch (error) {
    console.error('Error fetching places:', error);
    res.status(500).json({ error: 'Failed to fetch places' });
  }
});

export default mapRouter;
