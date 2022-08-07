import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  late TextEditingController currentPasswordC;
  late TextEditingController newPasswordC;
  late TextEditingController confirmPasswordC;

  /// MENANGANI HIDDEN PADA CURRENT PASSWORD
  RxBool isHiddenCurrentPass = true.obs;

  /// MENANGANI HIDDEN PADA CURRENT PASSWORD
  RxBool isHiddenNewPass = true.obs;

  /// MENANGANI HIDDEN PADA CURRENT PASSWORD
  RxBool isHiddenConfirmPass = true.obs;

  /// MENANGANI EFEK LOADING PADA BUTTON
  RxBool isLoading = false.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    currentPasswordC = TextEditingController();
    newPasswordC = TextEditingController();
    confirmPasswordC = TextEditingController();
  }

  @override
  void onClose() {
    currentPasswordC.dispose();
    newPasswordC.dispose();
    confirmPasswordC.dispose();
  }

  void updatePassword() async {
    /// CEK TIDAK KOSONG
    if (currentPasswordC.text.isNotEmpty &&
        newPasswordC.text.isNotEmpty &&
        confirmPasswordC.text.isNotEmpty) {
      /// CEK PASSWORD LAMA != NEW PASSWORD
      /// DAN CEK KONFIRMASI PASSWORD == NEW PASSWORD
      if (currentPasswordC.text != newPasswordC.text &&
          newPasswordC.text == confirmPasswordC.text) {
        isLoading.value = true;
        try {
          /// AMBIL DAN SIMPAN EMAIL AKTIF SAAT INI
          String currentEmail = auth.currentUser!.email!;

          /// CEK , APAKAH PASSWORD SEKARANG APAKAH SAMA DENGAN USER SAAT INI
          await auth.signInWithEmailAndPassword(
            email: currentEmail,
            password: currentPasswordC.text,
          );

          /// JIKA BENAR , LANJUT UPDATE PASSWORD
          await auth.currentUser!.updatePassword(newPasswordC.text);

          /// SIGNOUT DARI PASSWORD LAMA
          await auth.signOut();

          /// RELOGIN DENGAN PASSWORD BARU
          await auth.signInWithEmailAndPassword(
            email: currentEmail,
            password: newPasswordC.text,
          );

          /// KEMABLI KE PROFILE
          Get.back();

          /// NOTIF SUKSES
          Get.snackbar("Berhasil", "Password Berhasil di update");
        } on FirebaseAuthException catch (e) {
          if (e.code == "wrong-password") {
            Get.snackbar(
              "Terjadi Kesalahan",
              "Password yang dimasukan salah. Tidak dapat update password",
            );
          } else {
            Get.snackbar(
              "Terjadi Kesalahan",
              "Kesalahan pada ${e.code.toString().toLowerCase()}",
            );
          }
        } catch (e) {
          Get.snackbar(
            "Terjadi Kesalahan",
            "Tidak dapat update password",
          );
        } finally {
          isLoading.value = false;
        }
      } else {
        Get.snackbar(
          "Terjadi Kesalahan",
          "Password baru tidak boleh sama dengan password lama",
        );
      }
    } else {
      /// KETIKA KOSONG
      Get.snackbar(
        "Terjadi Kesalahan",
        "Form tidak boleh kosong",
      );
    }
  }
}
