const express = require("express");
const supabase = require("../db/conn"); // Import the singleton instance
const { SignInUser, SignUpUser, SignOut } = require("../controllers/auth.controller");

const router = express.Router();

router.post("/signup", SignUpUser); // api/v1/auth/signup
router.post("/signin", SignInUser); // api/v1/auth/signin
router.post("/signout", SignOut);   // api/v1/auth/signout

module.exports = router;
