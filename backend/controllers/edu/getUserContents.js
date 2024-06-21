import Content from "../../dbModels/content.js";

const getUserContents = async (req, res) => {
    try{
        const {category} = req.body;
        if(category === "All"){
            const contents = await Content.find({});
        }
        else{
            const contents = await Content.find({category});
        }
        const contentOwner = [];
        
    }
    catch(error){
        console.error('Error fetching user data:', error);
    }
}
export default getUserContents;