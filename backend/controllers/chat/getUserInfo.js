import User from "../../dbModels/user.js";

const userinfo = async (req, res) => {   
    const userId = req.params.id; 
    try {
        const user = await User.findOne({userId});
        res.status(200).json(user);
    } catch (error) {
        console.error('Error fetching user:', error.message);
        res.status(500).json({ error: 'Failed to fetch user' });
    }
}

export default userinfo;
