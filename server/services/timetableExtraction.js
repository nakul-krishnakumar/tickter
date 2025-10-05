const { GoogleGenAI } = require("@google/genai");
const supabase = require("../db/conn");

require("dotenv").config();

const ai = new GoogleGenAI({});

async function extractTimetableData(pdfBuffer) {
    try {
        const prompt = `
        You are an AI assistant. Extract timetable information from the PDF text below.
        The PDF contains timetables for multiple semesters and batches.
        Return ONLY a valid JSON array of timetables in this exact structure (NO explanations, NO extra text):

        [
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
                    "faculty": "Dr. Mathew C.D"
                }
                ]
            }
            ]
        }
        ]

        ## Important Instructions:
        1. Lab periods are always 2 hours → split into 1-hour slots in the JSON.
        2. Timetable is only Monday to Friday.
        3. All text values must be in title case (first letter capitalized).
        4. Return all timetables in a single JSON array.
        5. DO NOT wrap the response in markdown, code fences, or any extra text.
        6. Course should only be one of the following:
        - Computer Science and Engineering
        - Electronics and Communication Engineering
        - Cyber Security
        - Artificial Intelligence and Data Science
        `;

        const base64Pdf = pdfBuffer.toString("base64");

        const contents = [
            {
                inlineData: {
                    mimeType: "application/pdf",
                    data: base64Pdf,
                },
            },
            { text: prompt },
        ];

        const response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: contents,
        });

        let rawText = response.text.trim();

        // Remove any code fences if present
        rawText = rawText.replace(/```json|```/g, "").trim();

        const data = JSON.parse(rawText); // Should be an array of timetables

        for (const entry of data) {
            if (entry.course === "Computer Science and Engineering") {
                entry.course_code = "CSE";
            } else if (
                entry.course === "Electronics and Communication Engineering"
            ) {
                entry.course_code = "ECE";
            } else if (
                entry.course ===
                "Cyber Security"
            ) {
                entry.course_code = "CSY";
            } else if (
                entry.course ===
                "Artificial Intelligence and Data Science"
            ) {
                entry.course_code = "CSD";
            } else {
                entry.course_code = "CSE"; // fallback
            }
        }

        console.log(data);
        return data;
    } catch (error) {
        console.error("Error extracting timetable:", error);
        return null;
    }
}

async function insertMultipleTimetablesToDB(timetablesArray) {
    try {
        for (const timetableJson of timetablesArray) {
            // Insert timetable
            const { data: timetableData, error: timetableError } =
                await supabase
                    .from("timetables")
                    .insert([
                        {
                            semester: timetableJson.semester,
                            course: timetableJson.course,
                            course_code: timetableJson.course_code,
                            batch: timetableJson.batch,
                            academic_year: timetableJson.academicYear,
                        },
                    ])
                    .select("id")
                    .single();

            if (timetableError) throw timetableError;
            const timetableId = timetableData.id;

            // Prepare periods
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

            // Bulk insert periods
            const { error: periodsError } = await supabase
                .from("timetable_periods")
                .insert(periods);

            if (periodsError) throw periodsError;
        }

        console.log("All timetables + periods inserted successfully!");
        return null;
    } catch (err) {
        console.error("Error inserting timetables:", err);
        return err;
    }
}

module.exports = {
    extractTimetableData,
    insertMultipleTimetablesToDB,
};
