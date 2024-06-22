import Content from "../../dbModels/content.js";

const getUserContents = async (req, res) => {
    try {
        const { category } = req.body;
        if (category === "All") {
            const contents = await Content.find({});
            res.status(200).json({ userContents: contents });

        }
        else {
            const contents = await Content.find({ category });
            res.status(200).json({ userContents: contents });

        }
    }
    catch (error) {
        console.error('Error fetching user data:', error);
    }
}
export default getUserContents;