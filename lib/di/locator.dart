import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/modules/auth/services/auth_service.dart';
import 'package:junto/modules/chat/services/chat_service.dart';
import 'package:junto/modules/chat/services/push_notification_service.dart';
import 'package:junto/modules/home/services/home_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  /// Firebase Core
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  /// Services
  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(),
  );
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<HomeService>(() => HomeService());
}
