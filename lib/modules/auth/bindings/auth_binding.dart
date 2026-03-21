import 'package:get/get.dart';
import 'package:junto/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Keeps auth listener alive so Google/email sign-in can navigate off login reliably.
    Get.put(AuthController(), permanent: true);
  }
}







