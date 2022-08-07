// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_profile_controller.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  UpdateProfileView({Key? key}) : super(key: key);

  Map<String, dynamic> dataUser = Get.arguments;

  @override
  Widget build(BuildContext context) {
    /// MEMASUKAN DATA DARI ARGUMEN KE TextField
    controller.nipC.text = dataUser["nip"];
    controller.emailC.text = dataUser["email"];
    controller.nameC.text = dataUser["name"];
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            autocorrect: false,
            controller: controller.nipC,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("NIP"),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: controller.emailC,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Email"),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: controller.nameC,
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              controller.updateProfile(uid: dataUser["uid"].toString());
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("NAMA"),
            ),
          ),
          const SizedBox(height: 20),

          /// MENGAMBIL
          Text(
            "Foto Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<UpdateProfileController>(
                builder: (c) {
                  if (c.image != null) {
                    /// MENAMPILKAN IMAGE YANG BARUSAN DIPILIH
                    return ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.file(
                          File(c.image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    if (dataUser["profile"] != null &&
                        dataUser["profile"] != "") {
                      /// MENAMPILKAN IMAGE YANG SUDAH ADA SEBELUMNYA
                      return Column(
                        children: [
                          ClipOval(
                            child: Container(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                dataUser['profile'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          /// TEXTBUTTON DELETE
                          TextButton(
                            onPressed: () {
                              controller.deleteProfile(uid: dataUser['uid']);
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      );
                    } else {
                      /// JIKA KOSONG SEMUA
                      return Text("No Image");
                    }
                  }
                },
              ),

              /// TEXTBUTTON CHOOSE IMAGE
              TextButton(
                onPressed: () {
                  controller.pickImage();
                },
                child: Text("choose image"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse) {
                  await controller.updateProfile(
                    uid: dataUser["uid"].toString(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(Get.width, 40),
              ),
              child: Text(
                controller.isLoading.isFalse ? "UPDATE PROFILE" : "LOADING...",
                style: TextStyle(fontSize: 16, letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
