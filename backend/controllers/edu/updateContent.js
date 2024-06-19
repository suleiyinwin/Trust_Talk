import Content from "../../dbModels/content.js";
import { bucket } from '../../database/firebaseConfig.js';
import { v4 as uuidv4 } from 'uuid';


const updateContentData = async (req, res) => {
    try {
        const { contentId, title, content, contentImage, readingTime, category, date } = req.body;
        const buffer = Buffer.from(contentImage, 'base64');
        const image = uuidv4();
        const filename = `content_images/${image}`;
        const file = bucket.file(filename);
        await file.save(buffer, {
            metadata: { contentType: 'image/jpeg' },
            public: true,
        });
        const contenturl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

        await Content.findOneAndUpdate({ contentId }, { title, content, contenturl, readingTime, category, date });

        res.status(200).json({ message: 'Content updated successfully' });
    }
    catch (error) {
        console.error('Error updating content data:', error);
        res.status(500).send({ message: 'Error updating content data', error: error.message });
    }
}
export default updateContentData;