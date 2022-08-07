// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/new_password_controller.dart';

class NewPasswordView extends GetView<NewPasswordController> {
  const NewPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              autocorrect: false,
              controller: controller.newPassC,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                controller.newPass();
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("NEW PASSWORD"),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.newPass();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(Get.width, 40),
              ),
              child: const Text(
                "CONTINUE",
                style: TextStyle(fontSize: 16, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
