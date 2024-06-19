import Content from '../../dbModels/content.js';

const deleteContent = async (req, res) => {
    try {
        const { contentId } = req.body;
        await Content.deleteOne({ contentId });
        res.status(200).json({ message: 'Content deleted successfully' });
    }
    catch (error) {
        console.error('Error deleting content:', error);
        res.status(500).send({ message: 'Error deleting content', error: error.message });
    }
}
export default deleteContent;