const supabase = require("../db/conn");
const { extractTimetableData, insertTimetableToDB } = require("../services/timetableExtraction");

// Enhanced timetable upload with Hugging Face LLM parsing
async function uploadTimetable(req, res) {
    try {
        const file = req.file;

        if (!file) {
            return res.status(400).json({
                success: false,
                message: "Please upload a timetable image",
            });
        }

        console.log("Processing timetable image with AI...");
        console.log("File info:", {
            name: file.originalname,
            size: file.size,
            type: file.mimetype,
        });

        // Use enhanced AI parsing
        let timetableData;
        try {

            timetableData = await extractTimetableData(file.buffer);
            console.log(timetableData);
            console.log("AI parsing successful");

        } catch (aiError) {
            console.error("AI parsing failed", aiError);

            return res.status(500).json({
                success: false,
                message: aiError,
                data: {}
            })
        }

        // Save to database with enhanced structure
        const error = await insertTimetableToDB(timetableData);

        if (error) {
            console.error("Database save error:", error);
        }

        res.status(200).json({
            success: true,
            message: "Timetable uploaded and parsed successfully",
            data: {
                timetable: timetableData,
                summary: {
                    semester: timetableData.semester,
                    course: timetableData.course,
                    totalPeriods: timetableData.metadata?.totalPeriods || 0,
                    parsingMethod:
                        timetableData.metadata?.parsingMethod || "unknown",
                },
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

module.exports = {
    uploadTimetable,
};
