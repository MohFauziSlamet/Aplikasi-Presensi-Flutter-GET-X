import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPDATE PASSWORD '),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Obx(
            () => TextField(
              autocorrect: false,
              obscureText: controller.isHiddenCurrentPass.value,
              controller: controller.currentPasswordC,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Password Sekarang"),
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.isHiddenCurrentPass.toggle();
                  },
                  icon: controller.isHiddenCurrentPass.value
                      ? const Icon(Icons.remove_red_eye)
                      : const Icon(Icons.remove_red_eye_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => TextField(
              autocorrect: false,
              obscureText: controller.isHiddenNewPass.value,
              controller: controller.newPasswordC,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Password Baru"),
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.isHiddenNewPass.toggle();
                  },
                  icon: controller.isHiddenNewPass.value
                      ? const Icon(Icons.remove_red_eye)
                      : const Icon(Icons.remove_red_eye_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => TextField(
              autocorrect: false,
              obscureText: controller.isHiddenConfirmPass.value,
              controller: controller.confirmPasswordC,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                if (controller.isLoading.isFalse) {
                  controller.updatePassword();
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Konfirmasi Password"),
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.isHiddenConfirmPass.toggle();
                  },
                  icon: controller.isHiddenConfirmPass.value
                      ? const Icon(Icons.remove_red_eye)
                      : const Icon(Icons.remove_red_eye_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () {
                if (controller.isLoading.isFalse) {
                  controller.updatePassword();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(Get.width, 40),
              ),
              child: Text(
                controller.isLoading.isFalse ? "UPDATE PASSWORD" : "LOADING...",
                style: const TextStyle(fontSize: 16, letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
