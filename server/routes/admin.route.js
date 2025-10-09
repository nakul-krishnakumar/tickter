const express = require("express");
const multer = require("multer");
const path = require("path");

// Import controller
const {
    uploadTimetable,
    uploadCalendar,
} = require("../controllers/admin.controller");

const router = express.Router();

// Configure multer for file uploads
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
    },
    fileFilter: (req, file, cb) => {
        console.log("🔍 FILE FILTER CALLED - NEW VERSION");
        console.log("File filter - Original name:", file.originalname);
        console.log("File filter - Mimetype:", file.mimetype);

        // Allow images and PDFs
        const allowedExtensions = /\.(jpeg|jpg|png|gif|webp|pdf)$/i;
        const allowedMimetypes =
            /^(image\/(jpeg|jpg|png|gif|webp)|application\/pdf|application\/octet-stream)$/;

        const extname = allowedExtensions.test(file.originalname.toLowerCase());
        const mimetype = allowedMimetypes.test(file.mimetype);

        // Special handling for PDFs with octet-stream mimetype
        const isPdfFile = /\.pdf$/i.test(file.originalname);
        const isOctetStream = file.mimetype === "application/octet-stream";

        console.log("File filter - Extension valid:", extname);
        console.log("File filter - Mimetype valid:", mimetype);
        console.log("File filter - Is PDF file:", isPdfFile);
        console.log("File filter - Is octet-stream:", isOctetStream);

        // Accept if:
        // 1. Both extension and mimetype are valid, OR
        // 2. It's a PDF file with octet-stream mimetype (common in web uploads)
        if ((mimetype && extname) || (isPdfFile && isOctetStream)) {
            console.log("File filter - ACCEPTED");
            return cb(null, true);
        } else {
            console.log("File filter - REJECTED");
            cb(new Error("Only image files or PDFs are allowed"));
        }
    },
});

// Test endpoint to verify server is running latest code
router.get("/test", (req, res) => {
    res.json({
        message: "Admin routes working - UPDATED VERSION",
        timestamp: new Date().toISOString(),
    });
});

// Use "timetable" as the key for uploaded file
router.post("/upload-timetable", upload.single("timetable"), uploadTimetable);
router.post("/upload-calendar", upload.single("calendar"), uploadCalendar);

module.exports = router;
