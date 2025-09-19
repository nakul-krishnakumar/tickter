const express = require("express");
const { uploadPost } = require("../controllers/posts.controller");
const router = express.Router();

router.post("/upload", upload.array("images"), uploadPost); // api/v1/auth/signup
// router.patch("/edit/:postID", ); // api/v1/auth/signin
// router.delete("/delete/:postID", ); // api/v1/auth/signout

module.exports = router;
