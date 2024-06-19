import axios from 'axios';
import googleMapsConfig from '../../database/googleMapsConfig.js';

const API_KEY = googleMapsConfig.apiKey;

export const getNearbyPlaces = async (lat, lng, type, keyword) => {
  try {
    console.log(`Fetching nearby places for lat: ${lat}, lng: ${lng}, type: ${type}, keyword: ${keyword}`);
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', {
      params: {
        location: `${lat},${lng}`,
        radius: 5000,
        type: type,
        keyword: keyword,
        key: API_KEY,
      },
    });
    console.log('Places response data:', response.data);
    if (!response.data.results) {
      throw new Error('No results found');
    }
    return response.data.results;
  } catch (error) {
    console.error('Error fetching places data:', error);
    throw error;
  }
};

export const getPlaceDetails = async (placeId) => {
  try {
    console.log(`Fetching place details for placeId: ${placeId}`);
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/details/json', {
      params: {
        place_id: placeId,
        key: API_KEY,
      },
    });
    console.log('Place details response data:', response.data);
    if (!response.data.result) {
      throw new Error('No details found');
    }
    return response.data.result;
  } catch (error) {
    console.error('Error fetching place details:', error);
    throw error;
  }
};
