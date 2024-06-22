import admin from 'firebase-admin';
import nodemailer from 'nodemailer';
import User from '../../dbModels/user.js';
import dotenv from 'dotenv';
dotenv.config();

const transporter = nodemailer.createTransport({
  service: 'gmail', // You can use any email service
  auth: {
    user: process.env.EMAIL, // Your email address
    pass: process.env.EMAIL_PASSWORD // Your email password
  }
});

const passwordResetRequest = async (req, res) => {
  try {
    const { email } = req.body;
    console.log(`Received password reset request for email: ${email}`);

    const user = await User.findOne({ email });
    console.log(`Query result: ${user}`);

    if (!user) {
      return res.status(400).json({ error: 'Email does not exist' });
    }

    // Generate password reset link using Firebase Admin SDK
    const resetLink = await admin.auth().generatePasswordResetLink(email);
    console.log(`Generated password reset link: ${resetLink}`);

    // Send email using Nodemailer
    const mailOptions = {
      from: process.env.EMAIL,
      to: email,
      subject: 'Password Reset Link',
      text: `Click on the following link to reset your password: ${resetLink}`,
      html: `<p>Click on the following link to reset your password: <a href="${resetLink}">${resetLink}</a></p>`
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error('Error sending email:', error);
        return res.status(500).json({ error: 'Failed to send password reset email' });
      }
      console.log('Email sent:', info.response);
      res.status(200).json({ message: 'Password reset link sent successfully' });
    });

  } catch (error) {
    console.error('Error sending password reset link:', error.message);
    res.status(500).json({ error: 'Failed to send password reset link' });
  }
};

export default passwordResetRequest;
