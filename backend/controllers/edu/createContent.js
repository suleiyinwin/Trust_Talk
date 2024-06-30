import { v4 as uuidv4 } from 'uuid';
import Content from '../../dbModels/content.js';
import { bucket } from '../../database/firebaseConfig.js';


const createContent = async (req, res) => {

    try {
        const { expertId, title, content, contentImage, readingTime, category, date } = req.body;
        const contentId = uuidv4();

        const buffer = Buffer.from(contentImage, 'base64');
        const filename = `content_images/${contentId}`;
        const file = bucket.file(filename);
        await file.save(buffer, {
            metadata: { contentType: 'image/jpeg' },
            public: true,
        });
        const contenturl = `https://storage.googleapis.com/${bucket.name}/${filename}`;


        const newContent = new Content({
            contentId,
            expertId,
            title,
            content,
            contenturl,
            readingTime,
            category,
            date
        });
        await newContent.save();
        res.status(200).json({ message: 'Content created successfully' });
    }
    catch (error) {
        console.error('Error creating content:', error);
        res.status(500).send({ message: 'Error creating content', error: error.message });
    }
}


export default createContent;