const ContentSafetyClient = require("@azure-rest/ai-content-safety").default;
const { isUnexpected } = require("@azure-rest/ai-content-safety");
const { AzureKeyCredential } = require("@azure/core-auth");

require("dotenv").config();

// Azure credentials
const ENDPOINT = process.env.AZURE_ENDPOINT;
const key = process.env.AZURE_KEY;

// Create the client
const client = ContentSafetyClient(ENDPOINT, new AzureKeyCredential(key));

// Example: analyze text
async function moderateText(text) {
    try {
        const analyzeTextOption = { text: text };
        const analyzeTextParameters = { body: analyzeTextOption };

        const result = await client.path("/text:analyze").post(analyzeTextParameters);
        
        if (isUnexpected(result)) {
            throw new Error(`Unexpected response: ${result.status}`);
        }
        
        return await result.body;
    } catch (error) {
        console.error("Content moderation error:", error);
        throw error;
    }
}

module.exports = {
    moderateText
}