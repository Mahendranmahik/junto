import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../../core/values/strings.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              label: AppStrings.email,
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppStrings.password,
              controller: TextEditingController(),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: AppStrings.confirmPassword,
              controller: TextEditingController(),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: AppStrings.register,
              onPressed: () {
                controller.register();
              },
            ),
          ],
        ),
      ),
    );
  }
}


