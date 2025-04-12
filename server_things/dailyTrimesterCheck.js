const { MongoClient } = require("mongodb");

const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri);

let db;

async function connectToDatabase() {
  try {
    await client.connect();
    db = client.db("User");
    console.log("Connected to MongoDB");
  } catch (err) {
    console.error("MongoDB connection error:", err);
    process.exit(1);
  }
}

function getGATrimester(GA) {
  if (GA < 0 || isNaN(GA)) return "Invalid GA";

  const segments = [
    { upper: 12, label: "First Trimester" },
    { upper: 20, label: "Second Trimester" },
    { upper: 26, label: "Third Trimester" },
    { upper: 32, label: "Fourth Segment" },
    { upper: 34, label: "Fifth Segment" },
    { upper: 36, label: "Sixth Segment" },
    { upper: 38, label: "Seventh Segment" },
    { upper: 40, label: "Eighth Segment" },
    { upper: 42, label: "Full Term" },
  ];

  const totalWeeks = GA / 7;
  for (let segment of segments) {
    if (totalWeeks === segment.upper) {
      return segment.label;
    }
  }

  return "";
}

async function checkAndNotify(patient) {
  const { username, display_name, GA } = patient;
  const currentTrimester = getGATrimester(GA);

  if (currentTrimester === "Invalid GA") return;

  try {
    const patientRecord = await db.collection("patients_data").findOne({ username });
    const lastNotified = patientRecord?.lastNotifiedTrimester;

    if (lastNotified !== currentTrimester) {
      const title = `New Trimester Reached!`;
      const body = `Hi ${display_name}, you've entered the ${currentTrimester}.`;
      const timestamp = new Date();

      await db.collection("notifications_data").insertOne({ username, title, body, timestamp });

      await db.collection("patients_data").updateOne(
        { username },
        { $set: { lastNotifiedTrimester: currentTrimester } }
      );

      console.log(`📢 Notification sent to ${display_name}: ${currentTrimester}`);
    } else {
      console.log(`✅ ${display_name} is still in ${currentTrimester}. No notification needed.`);
    }
  } catch (error) {
    console.error("❌ Error in checkAndNotify:", error);
  }
}

async function runDailyCheck() {
  await connectToDatabase();

  const patients = await db.collection("patients_data").find({}, {
    projection: { _id: 0, password: 0, role: 0 }
  }).toArray();

  for (const patient of patients) {
    await checkAndNotify(patient);
  }

  console.log("✅ Daily Trimester Check completed.");
}

module.exports = { runDailyCheck }; // Export the function
