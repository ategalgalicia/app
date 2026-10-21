const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineString } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

initializeApp();

const region = defineString("ANNOUNCEMENTS_REGION", {
  description: "Cloud Functions region compatible with the Firestore location.",
});

const topics = new Set([
  "general", "santiago", "acoruna", "ferrol", "lalin",
  "monterroso", "ourense", "padron", "vigo",
]);

exports.sendAnnouncementPush = onDocumentCreated(
  {
    document: "announcements/{announcementID}",
    region,
    memory: "256MiB",
    minInstances: 0,
    maxInstances: 1,
    retry: false,
  },
  async (event) => {
    if (!event.data) return;

    const { title, body, topic } = event.data.data();
    const announcementID = event.params.announcementID;

    if (
      !topics.has(topic) ||
      typeof title !== "string" || !title.trim() ||
      typeof body !== "string" || !body.trim()
    ) {
      logger.warn("Invalid announcement; push skipped.", { announcementID });
      return;
    }

    const characters = Array.from(body);
    const preview = characters.length > 160
      ? characters.slice(0, 160).join("") + "…"
      : body;

    const messageID = await getMessaging().send({
      topic,
      notification: {
        title,
        body: preview,
      },
      data: {
        announcementID,
        topic,
      },
      android: {
        notification: { sound: "default" },
      },
      apns: {
        payload: {
          aps: {
            alert: { title, body: preview },
            sound: "default",
          },
        },
      },
    });

    logger.info("Announcement push sent.", { announcementID, messageID, topic });
  }
);
