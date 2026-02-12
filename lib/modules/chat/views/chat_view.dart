import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junto/modules/chat/controllers/chat_controller.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});

  final controller = Get.find<ChatController>();
  final textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userData = Get.arguments;

    return Scaffold(
      appBar: AppBar(title: Text(userData?["name"] ?? "Chat")),

      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (c, i) {
                  return ListTile(title: Text(controller.messages[i]));
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (textCtrl.text.isNotEmpty) {
                      controller.sendMessage(textCtrl.text);
                      textCtrl.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
