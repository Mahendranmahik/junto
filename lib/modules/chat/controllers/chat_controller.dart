import 'package:get/get.dart';

class ChatController extends GetxController {
  var messages = <String>[].obs;

  void sendMessage(String msg) {
    messages.add(msg);
  }
}



