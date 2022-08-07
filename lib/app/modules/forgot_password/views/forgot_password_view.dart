import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              autocorrect: false,
              controller: controller.emailC,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("EMAIL"),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.sendForgotPassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(Get.width, 40),
                ),
                child: Text(
                  controller.isLoading.isFalse
                      ? "SEND RESET PASSWORD"
                      : "LOADING...",
                  style: const TextStyle(fontSize: 16, letterSpacing: 2),
                ),
              ),
            ),
          ],
        ));
  }
}
