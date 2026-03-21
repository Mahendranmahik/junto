import 'package:get/get.dart';
import 'package:junto/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}







