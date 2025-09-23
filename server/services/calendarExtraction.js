const { GoogleGenAI } = require("@google/genai");
const supabase = require("../db/conn");
require("dotenv").config();

const ai = new GoogleGenAI({});

async function extractCalendarData(pdfBuffer) {
    try {
        const base64Pdf = pdfBuffer.toString("base64");

        const prompt = `
        You are an AI assistant. Extract all events from the academic calendar PDF below.
        Return ONLY a valid JSON array of events in this exact structure (NO explanations, NO extra text):

        [
          {
            "date": "12 Aug 2025",
            "eventName": "Independence Day",
            "source": "acadCalendar",
            "batch": [0],
            "semester": [1,2,3,4,5,6,7,8],
            "type": "holiday"
          }
        ]

        ## Important Instructions:
        1. The 'source' field must always be "acadCalendar" (ENUM: "acadCalendar", "email", "adminEntry").
        2. The 'batch' field should always be [0], meaning all batches.
        3. The 'semester' field should be an array of integers representing the affected semesters.
        4. The 'type' field is a string describing the type of event (e.g., "holiday", "exam", "activity", "deadline", "other").
        5. Dates must be in "DD MMM YYYY" format (e.g., 12 Aug 2025).
        6. If start and end times are mentioned, include them; otherwise, leave them null.
        7. Return all events in a single JSON array.
        8. DO NOT wrap the response in markdown, code fences, or any extra text.
        `;

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
        rawText = rawText.replace(/```json|```/g, "").trim();

        const events = JSON.parse(rawText);
        return events;
    } catch (error) {
        console.error("Error extracting calendar:", error);
        return null;
    }
}

async function insertCalendarToDB(eventsJson) {
    try {
        // Ensure optional fields exist and match DB schema
        const preparedEvents = eventsJson.map((e) => ({
            event_name: e.eventName,
            description: e.description || null,
            date: e.date,
            start_time: e.startTime || null,
            end_time: e.endTime || null,
            source: e.source, // must match source_enum
            batch: e.batch || [0], // default all batches
            semester: e.semester || [1, 2, 3, 4, 5, 6, 7, 8],
            type: e.type || "other",
        }));

        const { error } = await supabase.from("events").insert(preparedEvents);

        if (error) throw error;

        console.log("Academic calendar events inserted successfully!");
        return null;
    } catch (err) {
        console.error("Error inserting calendar:", err);
        return err;
    }
}

module.exports = {
    extractCalendarData,
    insertCalendarToDB,
};
