const express = require("express");
const cookieParser = require("cookie-parser");
const path = require("path");
const authRouter = require("./routes/auth.route");
const postRouter = require("./routes/posts.route");
const adminRouter = require("./routes/admin.route");

require("dotenv").config();

const app = express();

const PORT = process.env.PORT || 8081;
const HOST = process.env.HOST;

// CORS middleware - Add this BEFORE other middlewares
app.use((req, res, next) => {
    // Allow requests from Flutter web app (typically runs on different port)
    res.header("Access-Control-Allow-Origin", "*");
    res.header(
        "Access-Control-Allow-Methods",
        "GET, POST, PUT, DELETE, OPTIONS"
    );
    res.header(
        "Access-Control-Allow-Headers",
        "Origin, X-Requested-With, Content-Type, Accept, Authorization"
    );

    // Handle preflight requests
    if (req.method === "OPTIONS") {
        res.sendStatus(200);
    } else {
        next();
    }
});

// Global Middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

// Routes
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/posts", postRouter);
app.use("/api/v1/admin", adminRouter);

app.get("/", (req, res) => {
    res.status(200).json({
        message: "Welcome to Tickter!",
    });
});

// Start server with proper error handling
const server = app
    .listen(PORT, HOST, () => {
        console.log(`Server listening at http://${HOST}:${PORT}`);
    })
    .on("error", (err) => {
        if (err.code === "EADDRINUSE") {
            console.error(`❌ Port ${PORT} is already in use!`);
            console.error(
                `Please stop the other process or use a different port.`
            );
            process.exit(1);
        } else {
            console.error("❌ Server failed to start:", err.message);
            process.exit(1);
        }
    });

// Graceful shutdown handling
process.on("SIGINT", () => {
    console.log("\n🛑 Received SIGINT (Ctrl+C). Shutting down gracefully...");
    server.close(() => {
        console.log("✅ Server closed successfully");
        process.exit(0);
    });
});

process.on("SIGTERM", () => {
    console.log("\n🛑 Received SIGTERM. Shutting down gracefully...");
    server.close(() => {
        console.log("✅ Server closed successfully");
        process.exit(0);
    });
});
