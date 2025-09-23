const supabase = require("../db/conn");
const path = require("path");
const { moderateText,moderateImage } = require("../services/contentModeration");

// Handler for uploading a post with text and image
async function uploadPost(req, res) {
    try {
        const { title, content, author } = req.body;
        const files = req.files; // Array of images

        // Step 1: Moderate the text content before proceeding
        try {
            // Combine title and content for moderation
            const textToModerate = `${title || ""} ${content || ""}`.trim();

            if (textToModerate) {
                const moderationResult = await moderateText(textToModerate);
                console.log("Moderation result:", moderationResult);

                // Check if content violates policies (adjust thresholds as needed)
                const { categoriesAnalysis } = moderationResult;

                if (categoriesAnalysis) {
                    // Define severity thresholds (0-7 scale)
                    const SEVERITY_THRESHOLD = 2; // Adjust as needed

                    for (const category of categoriesAnalysis) {
                        if (category.severity >= SEVERITY_THRESHOLD) {
                            return res.status(400).json({
                                success: false,
                                message: `Content violates community guidelines: ${category.category}`,
                                category: category.category,
                                severity: category.severity,
                            });
                        }
                    }
                }
            }
        } catch (moderationError) {
            console.error("Content moderation failed:", moderationError);
            // You can choose to either block the post or allow it if moderation fails
            // For now, we'll log the error and continue
        }

        let imageUrls = [];

        // Step 2: Validate required fields
        if (!title || !content || !author) {
            return res.status(400).json({
                success: false,
                message: "Title, content, and author are required fields",
            });
        }

        // Step 3: Upload images to Supabase Storage
        if (files && files.length > 0) {
            for (const file of files) {
                // Run image moderation first
                try {
                    const moderationResult = await moderateImage(file.buffer);
                    console.log("Image moderation result:", moderationResult);

                    const { categoriesAnalysis } = moderationResult;
                    const SEVERITY_THRESHOLD = 2;

                    if (categoriesAnalysis) {
                        for (const category of categoriesAnalysis) {
                            if (category.severity >= SEVERITY_THRESHOLD) {
                                return res.status(400).json({
                                    success: false,
                                    message: `Image violates community guidelines: ${category.category}`,
                                    category: category.category,
                                    severity: category.severity,
                                });
                            }
                        }
                    }
                } catch (moderationError) {
                    console.error("Image moderation failed:", moderationError);
                    // You can choose whether to block the post or skip moderation errors
                }
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
