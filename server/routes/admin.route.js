const express = require("express");
const multer = require("multer");
const path = require("path");

// Debug the import
const {uploadTimetable } = require("../controllers/admin.controller");

const router = express.Router();

// Configure multer for file uploads
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|gif|webp/;
        const extname = allowedTypes.test(
            path.extname(file.originalname).toLowerCase()
        );
        const mimetype = allowedTypes.test(file.mimetype);

        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb(new Error("Only image files are allowed"));
        }
    },
});

// Ensure uploadTimetable function exists
if (typeof uploadTimetable !== "function") {
    console.error("ERROR: uploadTimetable is not a function!");
    process.exit(1);
}

router.post("/upload-timetable", upload.single("timetable"), uploadTimetable);

module.exports = router;
