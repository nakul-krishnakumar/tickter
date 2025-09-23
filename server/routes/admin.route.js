const express = require("express");
const multer = require("multer");
const path = require("path");

// Import controller
const { uploadTimetable, uploadCalendar } = require("../controllers/admin.controller");

const router = express.Router();

// Configure multer for file uploads
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
    },
    fileFilter: (req, file, cb) => {
        // Allow images and PDFs
        const allowedTypes = /jpeg|jpg|png|gif|webp|pdf/;
        const extname = allowedTypes.test(
            path.extname(file.originalname).toLowerCase()
        );
        const mimetype = allowedTypes.test(file.mimetype);

        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb(new Error("Only image files or PDFs are allowed"));
        }
    },
});

// Use "timetable" as the key for uploaded file
router.post("/upload-timetable", upload.single("timetable"), uploadTimetable);
router.post("/upload-calendar", upload.single("calendar"), uploadCalendar);

module.exports = router;
