import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  late TextEditingController emailC;

  /// MENANGANI LOADING PADA BUTTON LOGIN
  RxBool isLoading = false.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    emailC = TextEditingController();
  }

  @override
  void onClose() {
    emailC.dispose();
  }

  Future<void> sendForgotPassword() async {
    if (emailC.text.isNotEmpty) {
      isLoading.value = true; // MENAMPILKAN TULISAN LOADING
      /// EMAIL TIDAK KOSONG
      try {
        /// MENGIRIM LINK RESET PASSWORD
        await auth.sendPasswordResetEmail(email: emailC.text);
        Get.back();
        Get.snackbar(
          "BERHASIL",
          "Kami telah mengirimkan link reset password pada email kamu",
        );
        Future.delayed(const Duration(seconds: 1));
        Get.back();
      } catch (e) {
        Get.snackbar(
          "TERJADI KESALAHAN",
          "Tidak dapat mengirimkan reset password. Hubungi admin / Costumer service",
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      /// EMAIL KOSONG
      Get.snackbar(
        "TERJADI KESALAHAN",
        "Email tidak boleh kosong",
      );
    }
  }
}
