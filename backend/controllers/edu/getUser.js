import User from "../../dbModels/user.js";

const getUser = async (req, res) => {
    try {
        const { userId } = req.body;
        const user = await User.findOne({ userId });
        if (!user) {
            return res.status(404).send({ message: 'User not found' });
        }
        res.status(200).json({username: user.username });
    }
    catch (error) {
        console.error('Error fetching user data:', error);
        res.status(500).send({ message: 'Error fetching user data', error: error.message });
    }
}
export default getUser;