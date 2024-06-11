import Expert from "../../dbModels/expert.js";

const expertlist = async (req, res) => {
    try {
        const experts = await Expert.find();
        res.status(200).json(experts);
    } catch (error) {
        console.error('Error fetching experts:', error.message);
        res.status(500).json({ error: 'Failed to fetch experts' });
    }
}

export default expertlist;