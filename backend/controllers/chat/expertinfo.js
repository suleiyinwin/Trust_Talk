import Expert from "../../dbModels/expert.js";

const expertinfo = async (req, res) => {   
    const expertId = req.params.id; 
    try {
        const expert = await Expert.findOne({expertId});
        res.status(200).json(expert);
    } catch (error) {
        console.error('Error fetching expert:', error.message);
        res.status(500).json({ error: 'Failed to fetch expert' });
    }
}

export default expertinfo;
