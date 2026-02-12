import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junto/modules/auth/controllers/auth_controller.dart';
import 'package:junto/modules/auth/views/register_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await authController.login(
                  emailCtrl.text.trim(),
                  passCtrl.text.trim(),
                );
              },
              child: const Text("Login"),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterView()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}



