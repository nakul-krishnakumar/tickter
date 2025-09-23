const express = require("express");
const multer = require("multer");
const {
    uploadPost,
} = require("../controllers/posts.controller");

const router = express.Router();
const upload = multer(); // Use memory storage for file uploads

router.post("/upload", upload.array("images"), uploadPost); // api/v1/posts/upload
// router.patch("/edit/:postID", ); // api/v1/auth/signin
// router.delete("/delete/:postID", ); // api/v1/auth/signout

module.exports = router;
