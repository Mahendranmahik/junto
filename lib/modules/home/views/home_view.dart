import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junto/modules/home/controllers/home_controller.dart';
import 'package:junto/modules/auth/controllers/auth_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get AuthController (it should be available from AuthBinding)
    // If not available, create it
    AuthController authController;
    try {
      authController = Get.find<AuthController>();
    } catch (e) {
      authController = Get.put(AuthController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await Get.dialog<bool>(
                AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await authController.logout();
              }
            },
          ),
        ],
      ),

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
                title: Text(
                  data["name"],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  data["email"],
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: Icon(
                  data["isOnline"] ? Icons.circle : Icons.circle_outlined,
                  color: data["isOnline"] ? Colors.green : Colors.grey[600],
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



