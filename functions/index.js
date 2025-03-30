const { onRequest } = require("firebase-functions/v2/https");
const twilio = require("twilio");
const admin = require("firebase-admin");
if (!admin.apps.length) admin.initializeApp();

exports.sendWhatsAppMessage = onRequest(
  {
    timeoutSeconds: 60,
    secrets: ["TWILIO_SID", "TWILIO_TOKEN", "TWILIO_FROM", "TWILIO_CENTER_PHONE"]
  },
  async (req, res) => {
    const accountSid = process.env.TWILIO_SID;
    const authToken = process.env.TWILIO_TOKEN;
    const fromWhatsApp = process.env.TWILIO_FROM;
    const centerPhone = process.env.TWILIO_CENTER_PHONE;
    const client = twilio(accountSid, authToken);

    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }

    const { messageBody, userContact, sessionId, pickupRequestId } = req.body;

    if (!messageBody || !userContact || !sessionId || !pickupRequestId) {
      return res.status(400).send("Missing required fields");
    }

    try {
      // Send a freeform WhatsApp message
      const message = await client.messages.create({
        body: messageBody,
        from: fromWhatsApp,
        to: centerPhone,
      });

      // Store session for tracking the WhatsApp reply
      await admin.firestore().collection("sessions").doc(sessionId).set({
        from: centerPhone,
        confirmed: false,
        replied: false,
        timestamp: new Date(),
        pickupRequestId: pickupRequestId, // Link session to the pickup request
      });

      return res.status(201).send({ message: "Message sent", sid: message.sid });
    } catch (error) {
      console.error("❌ Twilio error:", error);
      return res.status(500).send({ error: error.message });
    }
  }
);

exports.handleWhatsAppReply = onRequest({ timeoutSeconds: 30 }, async (req, res) => {
  let message = req.body.Body?.trim(); // e.g., "1" or "2"
  let from = req.body.From;            // always "whatsapp:+919769338461"

  from = from.replace(/\s+/g, '');

  if (!message || !from) {
    return res.status(400).send("Missing required fields");
  }

  // Determine confirmation based on the reply ("1" for confirmation, "2" for rejection)
  const isConfirmed = (message === "1");

  try {
    // Query for the most recent pending session (replied == false) for this center
    const snapshot = await admin.firestore()
      .collection("sessions")
      .where("from", "==", from)
      .where("replied", "==", false)
      .orderBy("timestamp", "desc") // Most recent pending session first
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).send("No matching pending session found");
    }

    const sessionDoc = snapshot.docs[0];
    const sessionRef = sessionDoc.ref;
    const sessionData = sessionDoc.data();

    // Update the session to indicate that a reply has been received
    await sessionRef.update({
      confirmed: isConfirmed,
      replied: true,
    });

    // Update the corresponding pickup_request using the stored pickupRequestId
    if (sessionData.pickupRequestId) {
      const requestRef = admin.firestore().collection("pickup_requests").doc(sessionData.pickupRequestId);
      const newStatus = isConfirmed ? "successful" : "unavailable";
      await requestRef.update({ status: newStatus });
      console.log(`✅ Pickup request ${sessionData.pickupRequestId} updated to ${newStatus}`);
    } else {
      console.warn("No pickupRequestId found in the session document");
    }

    return res.status(200).send("Reply received and processed");
  } catch (error) {
    console.error("❌ handleWhatsAppReply error:", error);
    return res.status(500).send("Internal Server Error");
  }
});
