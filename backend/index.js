var admin = require("firebase-admin");
var serviceAccount = require("./google-service.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL:
    "https://vangtech2024-default-rtdb.asia-southeast1.firebasedatabase.app",
});

var db = admin.database();

var ref = db.ref("UltrasonicData/Sensor1");
ref.on("value", function (snapshot) {
  const updatedData = snapshot.val();
  handleCallback(updatedData, "Organik");
});

var ref = db.ref("UltrasonicData/Sensor2");
ref.on("value", function (snapshot) {
  const updatedData = snapshot.val();
  handleCallback(updatedData, "Anorganik");
});

var ref = db.ref("UltrasonicData/Sensor3");
ref.on("value", function (snapshot) {
  const updatedData = snapshot.val();
  handleCallback(updatedData, "Plastik");
});

function handleCallback(updatedData, name) {
  let title = "";
  let body = "";

  if (updatedData.Percentage < 10) {
    title = "Pemberitahuan";
    body = `Tempat sampah ${name}mu tersedia ${updatedData.Percentage}%. Silahkan Gunakan!`;
  } else if (updatedData.Percentage > 40) {
    title = "Peringatan";
    body = `Tempat sampah ${name}mu tersedia ${updatedData.Percentage}%. Hampir penuh!`;
  } else if (updatedData.Percentage > 75) {
    title = "Darurat";
    body = `Tempat sampah ${name}mu tersedia ${updatedData.Percentage}%. Segera Kosongkan!`;
  }

  const message = {
    notification: {
      title,
      body,
    },
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
