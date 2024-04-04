"use strict";

// Set your secret key. Remember to switch to your live secret key in production
// See your keys here: https://dashboard.stripe.com/apikeys
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
let badgeCount = 1;

exports.appCheck = functions.runWith({
  enforceAppCheck: true,
  // Opt-out: Requests with invalid App
  // Check tokens continue to your code.
})
    .https.onCall((data, context) => {
      // Now, requests with an invalid App Check token are not rejected.
      //
      // context.app will be undefined if the request:
      //   1) Does not include an App Check token
      //   2) Includes an invalid App Check token
      if (context.app == undefined) {
        // You can inspect the raw request header to check whether an App
        // Check token was provided in the request. If you're not ready to
        // fully enable App Check yet, you could log these conditions instead
        // of throwing errors.
        const rawToken = context.rawRequest.header["X-Firebase-AppCheck"];
        if (rawToken == undefined) {
          throw new functions.https.HttpsError(
              "failed-precondition",
              "The function must be called from an App Check verified app.",
          );
        } else {
          throw new functions.https.HttpsError(
              "unauthenticated",
              "Provided App Check token failed to validate.",
          );
        }
      }

      // Your function logic follows.
    });

exports.sendNotification = functions.database
    .ref("/Users/{bumperId}/Notify/{autoId}/text")
    .onCreate(async (snapshot, context) => {
      const bumperId = context.params.bumperId;
      const message = snapshot.val();

      functions.logger.log(
          "There was a new notification sent to:",
          bumperId,
      );

      functions.logger.log(
          "This is notification's message:",
          message,
      );

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = await admin.database()
          .ref(`/Users/${bumperId}/fcmToken`).once("value");

      // Get the receiver profile.
      const getReceiverProfilePromise = await admin.auth().getUser(bumperId);

      // The snapshot to the user's tokens.
      let tokensSnapshot = undefined;

      // The array containing all the user's tokens.
      let tokens = undefined;

      const results = await Promise
          .all([getDeviceTokensPromise, getReceiverProfilePromise]);
      tokensSnapshot = results[0];
      const follower = results[1];

      // Check if there are any device tokens.
      if (!tokensSnapshot.hasChildren()) {
        return functions.logger.log(
            "There are no notification tokens to send to.",
        );
      }
      functions.logger.log(
          "There are",
          tokensSnapshot.numChildren(),
          "tokens to send notifications to.",
      );
      functions.logger.log("Fetched receiver profile", follower);

      // Notification details.
      const payload = {
        notification: {
          title: "Bumpd",
          body: message,
          badge: badgeCount.toString(),
        },
      };
      badgeCount++;

      // Listing all tokens as an array.
      tokens = Object.keys(tokensSnapshot.val());
      // Send notifications to all tokens.
      const response = await admin.messaging().sendToDevice(tokens, payload);

      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          functions.logger.error(
              "Failure sending notification to",
              tokens[index],
              error,
          );
          // Cleanup the tokens who are not registered anymore.
          if (error.code === "messaging/invalid-registration-token" ||
              error.code === "messaging/registration-token-not-registered") {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index])
                .remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });

exports.sendInactiveUserNotifications = functions.https.onRequest(async (req, res) => {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - 7); // Calculate the date 7 days ago

  try {
    const usersRef = admin.database().ref("Users");
    const snapshot = await usersRef.once("value");

    snapshot.forEach((userSnapshot) => {
      const userData = userSnapshot.val();
      if (userData.lastActive < cutoffDate.getTime()) {
        // User is inactive, send them a push notification
        sendPushNotification(userData.fcmToken, "Don't be a stranger and start bumping.");
      }
    });

    res.status(200).send("Notifications sent successfully");
  } catch (error) {
    console.error("Error sending notifications:", error);
    res.status(500).send("Internal Server Error");
  }
});

function sendPushNotification(token, message) {
  const payload = {
    notification: {
      title: "Bumpd",
      body: message,
    },
  };

  admin.messaging().sendToDevice(token, payload)
      .then((response) => {
        console.log("Push notification sent:", response);
      })
      .catch((error) => {
        console.error("Error sending push notification:", error);
      });
}

// Function to send a push notification to inactive users
exports.checkUserActivity = functions.pubsub
    .schedule("every 2 minutes") // You can change the schedule as needed
    .timeZone("UTC")
    .onRun((context) => {
      console.logger.log("This will be run every 2 minutes!");
      return null;
    });
