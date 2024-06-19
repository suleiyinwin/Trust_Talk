import Content from "../../dbModels/content.js";
import Expert from "../../dbModels/expert.js";

const getContentData = async (req, res) => {
    try {
        const { contentId } = req.body;
        const content = await Content.findOne({ contentId });
        if (!content) {
            return res.status(404).send({ message: 'Content not found' });
        }
        const expert = await Expert.findOne({ expertId: content.expertId });
        res.status(200).json({ title: content.title, content: content.content, contenturl: content.contenturl, category: content.category, readingTime: content.readingTime, date: content.date, expertName: expert.name, expertProfile: expert.profileurl });
    }
    catch (error) {
        console.error('Error fetching content data:', error);
        res.status(500).send({ message: 'Error fetching content data', error: error.message });
    }
}

export default getContentData;