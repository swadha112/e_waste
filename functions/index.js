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

    const { messageBody, userContact, sessionId, disposalId } = req.body;

    if (!messageBody || !userContact || !sessionId || !disposalId) {
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
        disposalId: disposalId, // Link session to the disposal
      });

      return res.status(201).send({ message: "Message sent", sid: message.sid });
    } catch (error) {
      console.error("❌ Twilio error:", error);
      return res.status(500).send({ error: error.message });
    }
  }
);

exports.handleWhatsAppReply = onRequest({ timeoutSeconds: 30 }, async (req, res) => {
  const message = req.body.Body?.trim();
  const from = req.body.From;

  if (!message || !from) {
    return res.status(400).send("Missing required fields");
  }

  const isConfirmed = message === "1";

  try {
    const snapshot = await admin.firestore()
      .collection("sessions")
      .where("from", "==", from)
      .orderBy("timestamp", "desc")
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).send("No matching session");
    }

    const sessionDoc = snapshot.docs[0];
    const sessionRef = sessionDoc.ref;
    const sessionData = sessionDoc.data();

    // Update session status
    await sessionRef.update({
      confirmed: isConfirmed,
      replied: true,
    });

    // If confirmed, update the status in scheduled_disposals
    if (isConfirmed && sessionData.disposalId) {
      const disposalRef = admin.firestore().collection("scheduled_disposals").doc(sessionData.disposalId);
      await disposalRef.update({ status: "Successful" });

      console.log("✅ Disposal status updated to Successful for:", sessionData.disposalId);
    }

    return res.status(200).send("Reply received");
  } catch (error) {
    console.error("❌ handleWhatsAppReply error:", error);
    return res.status(500).send("Internal Server Error");
  }
});
