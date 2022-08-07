import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
  late TextEditingController newPassC;

  RxBool isHidden = true.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    newPassC = TextEditingController();
  }

  @override
  void onClose() {
    newPassC.dispose();
  }

  void newPass() async {
    try {
      /// KITA CEK , TextField TIDAK BOLEH KOSONG
      if (newPassC.text.isNotEmpty) {
        /// KITA CEK, PASSWORD TIDAK BOLEH SAMA "password"
        if (newPassC.text != "password") {
          /// JIKA TIDAK SAMA , KITA EKSEKUSI
          /// MENYIMPAN EMAIL
          String? email = auth.currentUser!.email;

          await auth.currentUser!.updatePassword(newPassC.text);

          await auth.signOut();

          await auth.signInWithEmailAndPassword(
            email: email!,
            password: newPassC.text,
          );

          Get.offAllNamed(Routes.HOME);
          Future.delayed(const Duration(seconds: 2)).then((_) {
            Get.snackbar("BERHASIL", "Kamu berhasil login");
          });
        } else {
          /// JIKA SAMA , MENAMPILKAN snackbar
          Get.snackbar(
            "TERJADI KESALAHAN",
            "Password harus diubah, jangan sama dengan 'password'",
          );
        }
      } else {
        /// JIKA KOSONG , MENAMPILKAN snackbar
        Get.snackbar(
          "TERJADI KESALAHAN",
          "Password tidak boleh kosong",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        /// MENAMPILKAN PESAN ERROR
        Get.snackbar("TERJADI KESALAHAN",
            "Password terlalu lemah. Setidaknya 6 karakter");
      }
    } catch (e) {
      /// MENAMPILKAN PESAN ERROR
      Get.snackbar(
        "TERJADI KESALAHAN",
        "Tidak dapat mengubah password, silahkan hubungi admin atau costumer service.",
      );
    }
  }
}
