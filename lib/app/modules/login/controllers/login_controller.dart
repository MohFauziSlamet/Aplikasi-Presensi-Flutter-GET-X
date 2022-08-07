// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:presence/app/routes/app_pages.dart';

class LoginController extends GetxController {
  late TextEditingController passC;
  late TextEditingController emailC;

  /// MENANGANI HIDDEN PADA PASSWORD
  RxBool isHidden = true.obs;

  /// MENANGANI LOADING PADA BUTTON LOGIN
  RxBool isLoading = false.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    passC = TextEditingController();
    emailC = TextEditingController();
  }

  @override
  void onClose() {
    passC.dispose();
    emailC.dispose();
  }

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;

      /// MENJALANKAN LOGIN
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: emailC.text,
          password: passC.text,
        );

        ///
        print(credential);

        /// CEK EMAIL APAKAH SUDAH DI VERIFIKASI
        if (credential.user != null) {
          if (credential.user!.emailVerified == true) {
            isLoading.value = false;
            if (passC.text == "password") {
              Get.toNamed(Routes.NEW_PASSWORD);
            } else {
              /// PINDAH KE HOME
              Get.offAllNamed(Routes.HOME);
              Future.delayed(Duration(seconds: 2)).then((_) {
                Get.snackbar("BERHASIL", "Kamu berhasil login");
              });
            }
          } else {
            isLoading.value = false;

            /// MENAMPILKAN PESAN ERROR
            /// DAN KIRIM ULANG KODE VERIFIKASI
            Get.defaultDialog(
              title: "BELUM VERIFIKASI",
              middleText:
                  "Email belum diverifikasi. Cek email kamu dan lakukan verifikasi",
              barrierDismissible: false,
              actions: [
                /// BATAL KIRIM
                TextButton(
                  onPressed: () {
                    isLoading.value = false;
                    Get.back(); // MENUTUP DIALOG
                  },
                  child: Text("CANCEL"),
                ),

                /// KIRIM ULANG VERIFIKASI
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await credential.user!.sendEmailVerification();
                      Get.back(); // MENUTUP DIALOG
                      Get.snackbar(
                        "BERHASIL",
                        "Kami telah mengirimkan verifikasi ke akun kamu",
                      );
                      isLoading.value = false;
                    } catch (e) {
                      Get.snackbar(
                        "TERJADI KESALAHAN",
                        "Tidak dapat mengirimkan verifikasi, Hubungi admin atau costumer service ",
                      );
                      isLoading.value = false;
                    }
                  },
                  child: Text("KIRIM ULANG"),
                ),
              ],
            );
          }
        }
        isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'user-not-found') {
          /// MENAMPILKAN PESAN ERROR
          Get.snackbar(
            "TERJADI KESALAHAN",
            "No user found for that email.",
          );
        } else if (e.code == 'wrong-password') {
          isLoading.value = false;

          /// MENAMPILKAN PESAN ERROR
          Get.snackbar(
            "TERJADI KESALAHAN",
            "Wrong password provided for that user.",
          );
        }
      } catch (e) {
        isLoading.value = false;

        /// MENAMPILKAN PESAN ERROR
        Get.snackbar(
          "TERJADI KESALAHAN",
          "Tidak dapat login!!!. ${e.toString()}",
        );
      }
    } else {
      /// EMAIL DAN PASSWORD KOSONG
      /// MENAMPILKAN PESAN ERROR
      Get.snackbar(
        "TERJADI KESALAHAN",
        "Email dan Password tidak boleh kosong",
      );
    }
  }
}
