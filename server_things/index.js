// index.js
const express = require("express");
const cors = require("cors");
const { MongoClient } = require("mongodb");
const bcrypt = require("bcrypt");

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

// Login API route
app.post("/api/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    // Check if user exists in the database
    const user = await db.collection("login_data").findOne({ username });
    if (user && await bcrypt.compare(password, user.password)) {
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

app.post("/api/register", async (req, res) => {
  const { username, password, name, role, EDC = "", GA = "", LMP = "", US = "", telephone = "" } = req.body;
  try {
    const existingUser = await db.collection("login_data").findOne({ username });
    if (existingUser) {
      return res.status(409).json({ success: false, message: "Username already exists" });
    }
    console.log("Registering user:", { username, password, name, role, EDC, GA, LMP, US, telephone });
    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert into login_data
    await db.collection("login_data").insertOne({
      username,
      password: hashedPassword,
      role,
    });

    // Insert into the appropriate collection
    if (role === "patient") {
      await db.collection("patients_data").insertOne({
        username,
        display_name: name,
        EDC,
        GA,
        LMP,
        US,
      });
    } else if (role === "nurse") {
      await db.collection("nurses_data").insertOne({
        username,
        display_name: name,
        role,
        telephone, // Store the telephone number for nurses
      });
    } else if (role == "admin") {
      await db.collection("admin_data").insertOne({
        username,
        display_name: name,
        role,
      });
    }

    res.status(201).json({ success: true, message: "User registered successfully" });
  } catch (err) {
    console.error("Error during registration:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post("/api/send_notification", async (req, res) => {
  const { username, title, body, timestamp } = req.body;
  console.log("Received notification data:", { username, title, body, timestamp });
  try {
    // Insert the message into the messages collection
    await db.collection("notifications_data").insertOne({ username, title, body, timestamp });
    res.status(201).json({ success: true, message: "Message sent successfully" });
  } catch (err) {
    console.error("Error sending message:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});
app.get("/api/notifications", async (req, res) => {
  try {
    // Fetch all messages from the messages collection
    const messages = await db.collection("messages").find({}).toArray();
    res.json(messages);
  } catch (err) {
    console.error("Error fetching messages:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Get all users
app.get("/api/users", async (_, res) => {
  try {
    const users = await db.collection("patients_data").find({}, {
      projection: { username: 1, display_name: 1 }
    }).toArray();
    
    console.log("Fetched users:", users); // Log the fetched users
    res.json(users);
  } catch (err) {
    console.error("Error fetching users:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

app.post("/api/get_user_data", async (req, res) => {
  const { username, role } = req.body;
  try {
    let collectionName;
    if (role === "patient") {
      collectionName = "patients_data";
    } else if (role === "nurse") {
      collectionName = "nurses_data";
    } else if (role === "admin") {
      collectionName = "admin_data";
    } else {
      return res.status(400).json({ success: false, message: "Invalid role" });
    }

    const userData = await db.collection(collectionName).findOne(
      { username },
      { projection: 
        { 
          _id: 0, 
          password: 0, 
          role: 0,
        } 
      } // Exclude the '_id', 'password', and 'role' fields
    );
    if (!userData) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.json(userData);
  } catch (err) {
    console.error("Error fetching user data:", err);
    res.status(500).json({ success: false, message: "Internal server error" });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
