const {
    extractTimetableData,
    insertMultipleTimetablesToDB,
} = require("../services/timetableExtraction");

const {
    extractCalendarData,
    insertCalendarToDB,
} = require("../services/calendarExtraction");

async function uploadTimetable(req, res) {
    try {
        const file = req.file;

        if (!file) {
            return res.status(400).json({
                success: false,
                message: "Please upload a timetable PDF",
            });
        }

        console.log("Processing timetable PDF with AI...");
        console.log("File info:", {
            name: file.originalname,
            size: file.size,
            type: file.mimetype,
        });

        // Use AI parsing
        let timetablesArray;
        try {
            timetablesArray = await extractTimetableData(file.buffer);
            console.log("Extracted timetables count:", timetablesArray.length);
        } catch (aiError) {
            console.error("AI parsing failed", aiError);
            return res.status(500).json({
                success: false,
                message: "AI parsing failed",
                error: aiError.message,
            });
        }

        // Save all extracted timetables to DB
        const dbError = await insertMultipleTimetablesToDB(timetablesArray);
        if (dbError) {
            console.error("Database save error:", dbError);
            return res.status(500).json({
                success: false,
                message: "Failed to save timetables to DB",
                error: dbError.message,
            });
        }

        res.status(200).json({
            success: true,
            message: "Timetables uploaded and parsed successfully",
            data: {
                totalTimetables: timetablesArray.length,
                timetables: timetablesArray,
            },
        });
    } catch (error) {
        console.error("Timetable upload error:", error);
        res.status(500).json({
            success: false,
            message: "Failed to process timetable",
            error: error.message,
        });
    }
}

async function uploadCalendar(req, res) {
    try {
        const file = req.file;

        if (!file) {
            return res.status(400).json({
                success: false,
                message: "Please upload a calendar PDF",
            });
        }

        console.log("Processing calendar PDF with AI...");
        console.log("File info:", {
            name: file.originalname,
            size: file.size,
            type: file.mimetype,
        });

        // Use AI parsing
        let calendarArray;
        try {
            calendarArray = await extractCalendarData(file.buffer);
            console.log(
                "Extracted calendar count:",
                calendarArray.length
            );
        } catch (aiError) {
            console.error("AI parsing failed", aiError);
            return res.status(500).json({
                success: false,
                message: "AI parsing failed",
                error: aiError.message,
            });
        }

        // Save all extracted calendar events to DB
        const dbError = await insertCalendarToDB(calendarArray);
        if (dbError) {
            console.error("Database save error:", dbError);
            return res.status(500).json({
                success: false,
                message: "Failed to save calendar to DB",
                error: dbError.message,
            });
        }

        res.status(200).json({
            success: true,
            message: "Calendar uploaded and parsed successfully",
            data: {
                totalEvents: calendarArray.length,
                calendar: calendarArray,
            },
        });
    } catch (error) {
        console.error("Calendar upload error:", error);
        res.status(500).json({
            success: false,
            message: "Failed to process calendar",
            error: error.message,
        });
    }
}

module.exports = {
    uploadTimetable,
    uploadCalendar
};
