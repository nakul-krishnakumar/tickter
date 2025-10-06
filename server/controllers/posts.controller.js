const supabase = require("../db/conn");
const path = require("path");
const { moderateText, moderateImage } = require("../services/contentModeration");

// Handler for uploading a post with text and image
async function uploadPost(req, res) {
  try {

    const { title, content, author } = req.body;
    console.log("Received author ID on server:", author); 
    const files = req.files; // Array of images

    // Step 1: Moderate the text content before proceeding
    try {
      const textToModerate = `${title || ""} ${content || ""}`.trim();
      if (textToModerate) {
        const moderationResult = await moderateText(textToModerate);
        console.log("Moderation result:", moderationResult);
        const { categoriesAnalysis } = moderationResult;
        if (categoriesAnalysis) {
          const SEVERITY_THRESHOLD = 2;
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
    }

    let imageUrls = [];

    // Step 2: Validate required fields (Note: title is not in your DB, but content and author are)
    if (!content || !author) {
      return res.status(400).json({
        success: false,
        message: "Content and author are required fields",
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
        }
        
        const fileExt = path.extname(file.originalname);
        const fileName = `${Date.now()}-${Math.random()
          .toString(36)
          .substring(2, 8)}${fileExt}`;
        
        // --- CHANGE 1: Use the correct bucket name 'posts_media' ---
        const { data, error } = await supabase.storage
          .from("posts_media")
          .upload(fileName, file.buffer, {
            contentType: file.mimetype,
            upsert: false,
          });

        if (error) {
          return res.status(400).json({ success: false, message: error.message });
        }

        // --- CHANGE 2: Get public URL from the correct bucket name 'posts_media' ---
        const { data: publicUrlData } = supabase.storage
          .from("posts_media")
          .getPublicUrl(fileName);

        imageUrls.push(publicUrlData.publicUrl);
      }
    }

    // --- CHANGE 3: Insert into the correct table 'posts' with the correct column names ---
    const { data: postData, error: postError } = await supabase
      .from("posts")
      .insert([
        {
          user_id: author, // 'author' from the request body maps to 'user_id'
          content: content,
          photo_url: imageUrls.length > 0 ? imageUrls[0] : null, // Use the first image URL
        },
      ])
      .select();

    if (postError) {
      return res.status(400).json({ success: false, message: postError.message });
    }

    res.status(201).json({ success: true, post: postData[0] });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}

async function searchPosts(req, res) {
  try {
    const { q, page = 1, limit = 20 } = req.query;
    if (!q) {
      return res.status(400).json({ error: "Missing search query" });
    }
    const offset = (page - 1) * limit;

    // --- CHANGE 4: Make sure this is querying the correct table name 'posts' ---
    const { data, error } = await supabase
      .from("posts")
      .select("*")
      .ilike("content", `%${q}%`)
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;
    return res.status(200).json({
      results: data,
      pagination: {
        page: Number(page),
        limit: Number(limit),
      },
    });
  } catch (err) {
    console.error("Search error:", err.message);
    return res.status(500).json({ error: "Failed to search posts" });
  }
}

module.exports = { uploadPost, searchPosts };