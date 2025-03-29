// index.js
const express = require("express");
const cors = require("cors");
const { MongoClient } = require("mongodb");

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Allow requests from Flutter app
app.use(express.json()); // Parse JSON body

// MongoDB Connection
const uri = "mongodb://localhost:27017"; // MongoDB connection URI
const client = new MongoClient(uri);

let db; // Variable to store the database connection

// Connect to MongoDB
async function connectToDatabase() {
  try {
    await client.connect();
    db = client.db("User"); // Connect to the "carebellmom" database
    console.log("Connected to MongoDB");

    // Log all collections in the database
    const collections = await db.listCollections().toArray();
    console.log("Collections in the database:", collections.map((col) => col.name));
  } catch (err) {
    console.error("MongoDB connection error:", err);
    process.exit(1); // Exit the application if the connection fails
  }
}
connectToDatabase();

// Simple route
app.get("/", (req, res) => {
  res.send("Backend is working!");
});

// Example API route
app.post("/api/echo", (req, res) => {
  const { message } = req.body;
  res.json({ received: message });
});

// Get all users
app.get("/api/users", async (_, res) => {
  try {
    const users = await db.collection("login_data").find({}).toArray();
    console.log("Fetched users:", users); // Log the fetched users
    res.json(users);
  } catch (err) {
    console.error("Error fetching users:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Login API route
app.post("/api/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    // Check if user exists in the database
    const user = await db.collection("login_data").findOne({ username, password });
    if (user) {
      res.json({
        success: true,
        message: "Login successful!",
        name: user.username,
        role: user.role, // Include the user's role in the response
      });
      console.log(user.role);
    } else {
      res.status(401).json({ success: false, message: "Invalid username or password" });
    }
  } catch (err) {
    console.error("Error during login:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
