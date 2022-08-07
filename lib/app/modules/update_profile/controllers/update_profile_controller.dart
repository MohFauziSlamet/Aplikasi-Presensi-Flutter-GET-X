import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fbStorage;

class UpdateProfileController extends GetxController {
  late TextEditingController nipC;
  late TextEditingController nameC;
  late TextEditingController emailC;

  /// MENANGANI EFEK LOADING PADA BUTTON
  RxBool isLoading = false.obs;

  /// INISIASI FIREABASE cloud_firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  fbStorage.FirebaseStorage storage = fbStorage.FirebaseStorage.instance;

  @override
  void onInit() {
    super.onInit();

    nipC = TextEditingController();
    nameC = TextEditingController();
    emailC = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    nipC.dispose();
    nameC.dispose();
    emailC.dispose();
  }

  /// ============ IMAGE PICKER ============
  final ImagePicker picker = ImagePicker();
  XFile? image;
  void pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print(image!.name);
      print(image!.name.split(".").last); // mengambil ekstention file Foto
      print(image!.path);
    } else {
      print(image);
    }

    update();
  }

  /// ============ UPDATE ALL PROFLIE ============
  Future<void> updateProfile({required String uid}) async {
    if (nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        nameC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        /// MENYIAPKAN DATA YANG AKAN DIUPDATE
        Map<String, dynamic> updateData = {
          "name": nameC.text,
        };

        /// MENGECEK IMAGE APAKAH TIDAK NULL
        /// JIKA NULL , TIDAK MELAKUKAN APA APA
        if (image != null) {
          /// MENAMBAHKAN PADA FIREABASE STORAGE DAN CLOUD FIRESTORE
          File file = File(image!.path);
          String ext = image!.name.split(".").last;

          print("MEMASUKAN FOTO KE FIREABASE STORAGE");
          await storage.ref('$uid/profile.$ext').putFile(file);
          String urlImage =
              await storage.ref("$uid/profile.$ext").getDownloadURL();

          /// SETELAH MENDAPATKAN URL
          /// KITA MASUKAN KE updateData LALU KE CLOUD FIRESTORE
          updateData.addAll(
            {
              "profile": urlImage,
            },
          );
        }

        /// MENGUPDATE DATA PADA cloud_firestore
        print("MEMASUKAN URL FOTO KE CLOUD FIRESTORE");
        await firestore.collection("pegawai").doc(uid).update(updateData);

        Get.back();
        Future.delayed(Duration(seconds: 1)).then(
            (_) => Get.snackbar("Berhasil", "Berhasil mengupdate profile"));
      } catch (e) {
        Get.snackbar(
          "Terjadi Kesalahan",
          "Tidak dapat mengupdate profile. Hubungi Admin",
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      /// JIKA KOSONG
      Get.snackbar(
        "Terjadi Kesalahan",
        "Form tidak boleh kosong",
      );
    }
  }

  /// ============ DELETE FOTO PROFLIE ============
  void deleteProfile({required String uid}) async {
    try {
      await firestore.collection("pegawai").doc(uid).update(
        {
          "profile": FieldValue.delete(),
        },
      );

      /// KEMBALI KE PROFILE
      Get.back();

      /// SUKSES
      Get.snackbar(
        "Berhasil",
        "Berhasil menghapus foto profile.",
      );
    } catch (e) {
      /// TERJADI ERROR
      Get.snackbar(
        "Terjadi Kesalahan",
        "Tidak dapat menghapus foto profile. Hubungi admin",
      );
    } finally {
      update();
    }
  }
}
