import Expert from "../../dbModels/expert.js";

const getExpertProfile = async (req, res) => {
    try{
        const { expertId } = req.body;
        const expert = await Expert.findOne({ expertId });
        if (!expert) {
            return res.status(404).send({ message: 'Expert not found' });
        }
        res.status(200).json({ expertProfile: expert.profileurl, expertName: expert.name});
    }
    catch (error) {
        console.error('Error fetching expert data:', error);
        res.status(500).send({ message: 'Error fetching expert data', error: error.message });
    }
}
export default getExpertProfile;