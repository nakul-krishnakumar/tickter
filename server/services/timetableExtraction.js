const { GoogleGenAI } = require("@google/genai");
const supabase = require("../db/conn");

require("dotenv").config();

// The client gets the API key from the environment variable `GEMINI_API_KEY`.
const ai = new GoogleGenAI({});

async function extractTimetableData(imageBuffer) {
    try {
        const prompt = `
        You are an AI assistant. Extract timetable information from the text below and return ONLY a valid JSON object in this exact structure (NO explanations, NO extra text):

        {
        "semester": 5,
        "course": "Computer Science and Engineering",
        "batch": 1,
        "academicYear": "2025",
        "timetable": [
            {
            "day": "Monday",
            "periods": [
                {
                "startTime": "09:00",
                "endTime": "09:55",
                "subject": {
                    "code": "IHS313",
                    "name": "Human Resource Management",
                    "type": "Theory"
                },
                "faculty": "Dr. Mathew C.D",
                }
            ]
            }
        ]
        }

        ## Points to Note:
        1. Lab periods are always 2 hours (e.g., 09:00 - 11:00 → split into two 1-hour slots).
        2. Timetable is only for Monday to Friday.
        3. All text values must be in title case (first letter capitalized).
        4. DO NOT wrap the response in markdown or code fences.
        `;
        
        const base64Image = imageBuffer.toString("base64");

        const contents = [
            {
                inlineData: {
                mimeType: "image/jpeg",
                data: base64Image,
                },
            },
            { text: prompt },
        ];

        const response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: contents,
        });
        
        let rawText = response.text.trim();

        // Strip ```json ... ``` if present
        rawText = rawText.replace(/```json|```/g, "").trim();

        console.log("Cleaned response:", rawText);

        const data = JSON.parse(rawText);

        return data;

    } catch (error) {
        console.error("Error extracting timetable:", error);
        return null;
    }
}

async function insertTimetableToDB(timetableJson) {
    try {
        // Insert into timetables
        const { data: timetableData, error: timetableError } = await supabase
            .from("timetables")
            .insert([
                {
                    semester: timetableJson.semester,
                    course: timetableJson.course,
                    batch: timetableJson.batch,
                    academic_year: timetableJson.academicYear,
                },
            ])
            .select("id")
            .single();

        if (timetableError) throw timetableError;

        const timetableId = timetableData.id;

        // Prepare all periods
        const periods = [];
        for (const dayObj of timetableJson.timetable) {
            for (const period of dayObj.periods) {
                periods.push({
                    timetable_id: timetableId,
                    day: dayObj.day,
                    start_time: period.startTime,
                    end_time: period.endTime,
                    subject_code: period.subject.code || null,
                    subject_name: period.subject.name || null,
                    subject_type: period.subject.type || null,
                    faculty: period.faculty || null,
                });
            }
        }

        // Bulk insert into timetable_periods
        const { error: periodsError } = await supabase
            .from("timetable_periods")
            .insert(periods);

        if (periodsError) throw periodsError;

        console.log("Timetable + periods inserted successfully!");
        return null;
    } catch (err) {
        console.error("Error inserting timetable:", err);
        return err;
    }
}

module.exports = {
    extractTimetableData,
    insertTimetableToDB
};
