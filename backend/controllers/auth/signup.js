import User from '../../dbModels/user.js';

const signup = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    const existingUser = await User.findOne({ $or: [{ username }, { email }] });
    if (existingUser) {
      return res.status(400).json({ message: 'Username or email already exists' });
    }
    const userRecord = await admin.auth().createUser({
      email,
      password,
    });

    const user = new User({
      userId: userRecord.uid,
      username,
      email,
      profileurl: '',
    });
    await user.save();

    res.status(200).json({ message: 'User signed up successfully' });
  } catch (error) {
    console.error('Error signing up user:', error);
    res.status(500).json({ message: 'Failed to sign up user' });
  }
}

export default signup;