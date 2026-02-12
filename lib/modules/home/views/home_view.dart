import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junto/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),

      body: StreamBuilder<QuerySnapshot>(
        stream: controller.homeService.getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;

              if (data["uid"] == controller.homeService.myUid) {
                return SizedBox();
              }

              return ListTile(
                title: Text(data["name"]),
                subtitle: Text(data["email"]),
                trailing: Icon(
                  data["isOnline"] ? Icons.circle : Icons.circle_outlined,
                  color: data["isOnline"] ? Colors.green : Colors.grey,
                  size: 12,
                ),
                onTap: () {
                  Get.toNamed("/chat", arguments: data);
                },
              );
            },
          );
        },
      ),
    );
  }
}



