import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_data_kit_firebase/src/map_firebase.dart';

/// Minimal FCM helpers. Full messaging UX (handlers, local notifications)
/// stays in the app.
class FirebaseMessagingHelper {
  FirebaseMessagingHelper(this.messaging);

  final FirebaseMessaging messaging;

  /// Requests notification permission (iOS / web). Maps failures via [mapFirebase].
  Future<bool> requestPermission() => mapFirebase(() async {
    final settings = await messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  });

  /// Current FCM registration token, or null if unavailable.
  Future<String?> getToken() => mapFirebase(messaging.getToken);
}
