const supabase = require("../db/conn");

async function SignUpUser(req, res) {
    try {
        const { email, password, ...userData } = req.body;

        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: userData,
            },
        });

        if (error) {
            return res.status(400).json({
                success: false,
                message: error.message,
            });
        }

        res.status(201).json({
            success: true,
            message: "User created successfully",
            user: data.user,
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error",
            error: error.message,
        });
    }
}

async function SignInUser(req, res) {
    try {
        const { email, password } = req.body;

        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            return res.status(401).json({
                success: false,
                message: error.message,
            });
        }

        res.status(200).json({
            success: true,
            message: "Sign in successful",
            user: data.user,
            session: data.session,
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error",
            error: error.message,
        });
    }
}

async function SignOut(req, res) {
    try {
        const { error } = await supabase.auth.signOut();

        if (error) {
            return res.status(400).json({
                success: false,
                message: error.message,
            });
        }

        res.status(200).json({
            success: true,
            message: "Sign out successful",
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
}

module.exports = {
    SignUpUser,
    SignInUser,
    SignOut
};
