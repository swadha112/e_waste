const { onRequest } = require("firebase-functions/v2/https");
const functions      = require("firebase-functions");
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

    // Note the additional fields: documentId and collectionName.
    const { messageBody, userContact, sessionId, documentId, collectionName } = req.body;

    if (!messageBody || !userContact || !sessionId || !documentId || !collectionName) {
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
        documentId: documentId,         // This could be pickupRequestId or scheduledPickupId
        collectionName: collectionName, // e.g., "pickup_requests" or "Scheduled_pickup"
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
  let from = req.body.From;            // e.g., "whatsapp:+919769338461"

  from = from.replace(/\s+/g, ''); // Normalize phone number

  if (!message || !from) {
    return res.status(400).send("Missing required fields");
  }

  // Determine confirmation based on the reply ("1" for confirmation)
  const isConfirmed = (message === "1");

  try {
    // Query for the most recent pending session for this phone
    const snapshot = await admin.firestore()
      .collection("sessions")
      .where("from", "==", from)
      .where("replied", "==", false)
      .orderBy("timestamp", "desc")
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).send("No matching pending session found");
    }

    const sessionDoc = snapshot.docs[0];
    const sessionRef = sessionDoc.ref;
    const sessionData = sessionDoc.data();

    // Update the session to indicate a reply has been received
    await sessionRef.update({
      confirmed: isConfirmed,
      replied: true,
    });

    // Use the stored documentId and collectionName to update the proper Firestore document
    if (sessionData.documentId && sessionData.collectionName) {
      const requestRef = admin.firestore().collection(sessionData.collectionName).doc(sessionData.documentId);
      const newStatus = isConfirmed ? "successful" : "unavailable";
      await requestRef.update({ status: newStatus });
      console.log(`✅ Document ${sessionData.documentId} in ${sessionData.collectionName} updated to ${newStatus}`);
    } else {
      console.warn("No documentId or collectionName found in session");
    }

    return res.status(200).send("Reply received and processed");
  } catch (error) {
    console.error("❌ handleWhatsAppReply error:", error);
    return res.status(500).send("Internal Server Error");
  }
});

// 3) Scheduled stock updates (v2 Scheduler)
// ——————————————
const { onSchedule } = require("firebase-functions/v2/scheduler");

exports.updateStocks = onSchedule("every 5 minutes", async (event) => {
  const db = admin.firestore();
  const snap = await db.collection("stocks").get();
  const batch = db.batch();

  snap.docs.forEach((doc) => {
    const d = doc.data();
    const oldPrice   = d.currentPrice  || 0;
    const oldHistory = Array.isArray(d.history) ? d.history : [];
    const oldSupply  = d.supply         || 1;
    const oldDemand  = d.demand         || 1;

    // 1) supply/demand ±10
    const supplyChange = Math.floor(Math.random()*21) - 10;
    const demandChange = Math.floor(Math.random()*21) - 10;
    const newSupply    = Math.max(1, oldSupply + supplyChange);
    const newDemand    = Math.max(1, oldDemand + demandChange);

    // 2) price swing ±5% + imbalance bias ±3%
    const rndPct     = Math.random()*0.1 - 0.05;
    const imbalance  = (newDemand - newSupply)/(newDemand + newSupply);
    const biasPct    = Math.max(-0.03, Math.min(0.03, imbalance * 0.1));
    const newPrice   = Math.max(10, Math.round(oldPrice*(1 + rndPct + biasPct)));

    // 3) roll history window (last 9 + new)
    const newHistory = oldHistory.slice(-9);
    newHistory.push(newPrice);

    // 4) batch update
    batch.update(doc.ref, {
      currentPrice: newPrice,
      history:      newHistory,
      supply:       newSupply,
      demand:       newDemand,
      lastUpdated:  admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`updateStocks: ${snap.size} docs updated`);
});