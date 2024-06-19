import Content from "../../dbModels/content.js";

const expertContents = async (req, res) => {
    try {
        const { expertId } = req.body;
        const contents = await Content.find({ expertId });
        res.status(200).json({ expertContents: contents });
    } catch (error) {
        console.error('Error fetching expert data:', error);
        res.status(500).send({ message: 'Error fetching expert data', error: error.message });
    }
}

export default expertContents;