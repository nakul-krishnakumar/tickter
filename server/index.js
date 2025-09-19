const express = require("express");
const cookieParser = require("cookie-parser");
const path = require("path");
const authRouter = require("./routes/auth.route");
const postRouter = require("./routes/posts.route");

require("dotenv").config();

const app = express();

const PORT = process.env.PORT || 8081;
const HOST = process.env.HOST;

// Global Middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

// Routes
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/posts", postRouter);

app.get("/", (req, res) => {
    res.status(200).json({
        message: "Welcome to Tickter!",
    });
});

app.listen(PORT, HOST, () => {
    console.log(`Server listening at http://${HOST}:${PORT}`);
});
