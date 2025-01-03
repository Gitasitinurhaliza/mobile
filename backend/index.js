var admin = require("firebase-admin");
var serviceAccount = require("./google-service.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL:
    "https://vangtech2024-default-rtdb.asia-southeast1.firebasedatabase.app",
});

var db = admin.database();

// Store notification intervals for each sensor
const emergencyIntervals = {
  Sensor1: null,
  Sensor2: null,
  Sensor3: null,
};

var ref = db.ref("UltrasonicData/Sensor1");
ref.on("value", function (snapshot) {
  const updatedData = snapshot.val();
  handleCallback(updatedData, "Organik", "Sensor1");
});

var ref = db.ref("UltrasonicData/Sensor2");
ref.on("value", function (snapshot) {
  const updatedData = snapshot.val();
  handleCallback(updatedData, "Anorganik", "Sensor2");
});

var ref = db.ref("UltrasonicData/Sensor3");
ref.on("value", function (snapshot) {
  const updatedData = snapshot.val();
  handleCallback(updatedData, "Botol Plastik", "Sensor3");
});

function startEmergencyNotifications(data, name, sensorId) {
  // Clear any existing interval for this sensor
  if (emergencyIntervals[sensorId]) {
    clearInterval(emergencyIntervals[sensorId]);
  }

  // Create message
  const message = {
    notification: {
      title: "Darurat",
      body: `Tingkat Tempat sampah ${name}mu ${data.Percentage}%. Segera Kosongkan!`,
    },
    topic: "all_users",
  };

  // Immediately send first notification
  sendEmergencyNotification(message, name, data.Percentage);

  // Set up the interval for subsequent notifications (every 5 minutes)
  const interval = setInterval(() => {
    sendEmergencyNotification(message, name, data.Percentage);
  }, 5 * 60 * 1000); // 5 minutes interval

  // Store the interval
  emergencyIntervals[sensorId] = interval;
}

function sendEmergencyNotification(message, name, percentage) {
  admin
    .messaging()
    .send(message)
    .then((response) => {
      console.log("Successfully sent emergency message:", response);

      const databaseRef = admin.database().ref("Notifications");
      const newNotification = {
        title: "Darurat",
        body: `Tingkat Tempat sampah ${name}mu ${percentage}%. Segera Kosongkan!`,
        timestamp: Date.now(),
      };

      databaseRef.push(newNotification, (error) => {
        if (error) {
          console.error("Error saving notification to database:", error);
        } else {
          console.log("Emergency notification saved to database successfully!");
        }
      });
    })
    .catch((error) => {
      console.log("Error sending emergency message:", error);
    });
}

function handleCallback(updatedData, name, sensorId) {
  let title = "";
  let body = "";

  if (updatedData.Percentage > 75) {
    // Start emergency notifications if they're not already running
    if (!emergencyIntervals[sensorId]) {
      console.log(`Starting emergency notifications for ${name}`);
      startEmergencyNotifications(updatedData, name, sensorId);
    }
  } else {
    // Clear emergency notifications if they're running
    if (emergencyIntervals[sensorId]) {
      clearInterval(emergencyIntervals[sensorId]);
      emergencyIntervals[sensorId] = null;
      console.log(
        `Emergency notifications stopped for ${name} - levels returned to normal`
      );
    }

    // Handle other notification cases
    if (updatedData.Percentage < 10) {
      title = "Pemberitahuan";
      body = `Tingkat Tempat sampah ${name}mu ${updatedData.Percentage}%. Silahkan Gunakan!`;
    } else if (updatedData.Percentage > 40) {
      title = "Peringatan";
      body = `Tingkat Tempat sampah ${name}mu ${updatedData.Percentage}%. Hampir penuh!`;
    } else {
      return;
    }

    // Send single notification for non-emergency cases
    const message = {
      notification: { title, body },
      topic: "all_users",
    };

    admin
      .messaging()
      .send(message)
      .then((response) => {
        console.log("Successfully sent message:", response);

        const databaseRef = admin.database().ref("Notifications");
        const newNotification = {
          title,
          body,
          timestamp: Date.now(),
        };

        databaseRef.push(newNotification, (error) => {
          if (error) {
            console.error("Error saving notification to database:", error);
          } else {
            console.log("Notification saved to database successfully!");
          }
        });
      })
      .catch((error) => {
        console.log("Error sending message:", error);
      });
  }
}
