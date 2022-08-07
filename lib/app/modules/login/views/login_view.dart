import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
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
            Obx(() => TextField(
                  autocorrect: false,
                  obscureText: controller.isHidden.value,
                  controller: controller.passC,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    controller.login();
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        controller.isHidden.toggle();
                      },
                      icon: controller.isHidden.value
                          ? const Icon(Icons.remove_red_eye)
                          : const Icon(Icons.remove_red_eye_outlined),
                    ),
                    label: const Text("PASSWORD"),
                  ),
                )),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.login();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(Get.width, 40),
                ),
                child: Text(
                  controller.isLoading.isFalse ? "LOGIN" : "LOADING...",
                  style: const TextStyle(fontSize: 16, letterSpacing: 2),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(Routes.FORGOT_PASSWORD);
              },
              child: const Text("Lupa password ?"),
            ),
          ],
        ),
      ),
    );
  }
}
