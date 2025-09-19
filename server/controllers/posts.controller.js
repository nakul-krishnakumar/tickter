const supabase = require("../db/conn");
const path = require("path");

// Handler for uploading a post with text and image
async function uploadPost(req, res) {
    try {
        const { title, content, author } = req.body;
        const files = req.files; // Array of images

        let imageUrls = [];

        if (files && files.length > 0) {
            for (const file of files) {
                const fileExt = path.extname(file.originalname);
                const fileName = `${Date.now()}-${Math.random()
                    .toString(36)
                    .substring(2, 8)}${fileExt}`;
                const { data, error } = await supabase.storage
                    .from("post-images")
                    .upload(fileName, file.buffer, {
                        contentType: file.mimetype,
                        upsert: false,
                    });

                if (error) {
                    return res
                        .status(400)
                        .json({ success: false, message: error.message });
                }

                // Get public URL for the uploaded image
                const { data: publicUrlData } = supabase.storage
                    .from("post-images")
                    .getPublicUrl(fileName);

                imageUrls.push(publicUrlData.publicUrl);
            }
        }

        // Insert post into DB
        const { data: postData, error: postError } = await supabase
            .from("posts")
            .insert([{ title, content, author, image_urls: imageUrls }])
            .select();

        if (postError) {
            return res
                .status(400)
                .json({ success: false, message: postError.message });
        }

        res.status(201).json({ success: true, post: postData[0] });
    } catch (err) {
        res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
}

module.exports = { uploadPost };
