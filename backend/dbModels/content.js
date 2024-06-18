import mongoose from 'mongoose';

const contentSchema = new mongoose.Schema({
    contentId: { type: String, required: true, unique: true },
    expertId : { type: String, required: true },
    title: { type: String, required: true },
    content: { type: String, required: true },
    contenturl: { type: String, required: true },
    readingTime: { type: String, required: true },
    category : { type: String, required: true },
    date: { type: String, required: true },
  });

const Content = mongoose.model('contents', contentSchema);
export default Content;