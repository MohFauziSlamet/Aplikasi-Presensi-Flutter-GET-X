// ignore_for_file: unused_local_variable, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPegawaiController extends GetxController {
  late TextEditingController nipC;
  late TextEditingController nameC;
  late TextEditingController jobC;
  late TextEditingController emailC;
  late TextEditingController passwordAdmin;

  /// MENANGANI HIDDEN PADA PASSWORD
  RxBool isHidden = true.obs;

  /// MENANGANI EFEK LOADING PADA BUTTON
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  /// INISIASI FIREABASE cloud_firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();

    nipC = TextEditingController();
    nameC = TextEditingController();
    jobC = TextEditingController();
    emailC = TextEditingController();
    passwordAdmin = TextEditingController();
  }

  @override
  void onClose() {
    nipC.dispose();
    nameC.dispose();
    jobC.dispose();
    emailC.dispose();
    passwordAdmin.dispose();
  }

  Future<void> addPegawai() async {
    if (nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        jobC.text.isNotEmpty &&
        nameC.text.isNotEmpty) {
      isLoading.value = true; // BUTTON MENAMPILKAN LOADING
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            const Text("Masukan password untuk validasi admin!"),
            const SizedBox(height: 10),
            Obx(
              () => TextField(
                autocorrect: false,
                obscureText: isHidden.value,
                controller: passwordAdmin,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      isHidden.toggle();
                    },
                    icon: isHidden.value
                        ? const Icon(Icons.remove_red_eye)
                        : const Icon(Icons.remove_red_eye_outlined),
                  ),
                  label: const Text("PASSWORD"),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              isLoading.value = false;
              Get.back();
            },
            child: const Text("CANCEL"),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (isLoadingAddPegawai.isFalse) {
                  await prosesAddPegawai();
                }
                isLoading.value = false;
              },
              child: Text(
                isLoadingAddPegawai.isFalse ? "ADD PEGAWAI" : "LOADING...",
              ),
            ),
          ),
        ],
      );
    } else {
      /// JIKA FIELD KOSONG
      Get.snackbar("TERJADI KESALAHAN", " Semua FORM TIDAK BOLEH KOSONG");
    }
  }

  /// FUNCTION PECAHAN DARI addPegawai()
  Future<void> prosesAddPegawai() async {
    isLoadingAddPegawai.value = true;

    /// KITA CEK , PASSWORD VALIDASI TIDAK BOLEH KOSONG
    if (passwordAdmin.text.isNotEmpty) {
      try {
        /// KITA SIMPAN EMAIL currentUser
        String emailUser = auth.currentUser!.email!;

        /// MENGECEK PASSWORD VALIDASI , DENGAN CARA LOGIN DENGAN PASSWORD VALIDASI
        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
          email: emailUser,
          password: passwordAdmin.text,
        );

        /// MENAMBAHKAN PEGAWAI
        UserCredential pegawaiCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        /// JIKA BERHASIL LOGIN & ADA UID => DIMASUKAN KEDALAM VARIABEL
        /// LALU MEMASUKAN DATA KEDALAM FIREABASE
        /// JIKA GAGAL , TIDAK MELAKIKAN APA APA
        if (pegawaiCredential.user != null) {
          /// MENAMPUNG UID
          String uid = pegawaiCredential.user!.uid;

          /// MENAMBAHKAN KEDALAM COLLCETION DB FIREABASE
          print("MENAMBAHKAN DATA PEGAWAI KEDALAM COLLCETION DB FIREABASE");
          await firestore.collection("pegawai").doc(uid).set(
            {
              "nip": nipC.text,
              "name": nameC.text,
              "job": nameC.text,
              "email": emailC.text,
              "role": "pegawai",
              "uid": uid,
              "createdAt": DateTime.now().toIso8601String(),
            },
          );

          /// MENGIRIM EMAIL VERIFICATION
          print("MENGIRIM EMAIL VERIFICATION");
          await pegawaiCredential.user!.sendEmailVerification();

          await auth.signOut();

          /// LOGIN KEMBALI
          UserCredential userCredentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: emailUser,
            password: passwordAdmin.text,
          );

          Get.back(); // MENUTUP DIALOG

          /// MENAMPILKAN DIALOG SUKSES
          Get.defaultDialog(
            title: "BERHASIL",
            middleText: "Silahkan lakukan verifikasi email anda.",
            onConfirm: () {
              Get.back(); // MENUTUP DIALOG
              Get.back(); // KEMBALI KE HOME
            },
          );
          isLoadingAddPegawai.value = false;
        }
      } on FirebaseAuthException catch (e) {
        isLoadingAddPegawai.value = false;
        if (e.code == "weak-password") {
          Get.snackbar(
            "TERJADI KESALAHAN",
            "Password yang digunakan terlalu singkat",
          );
        } else if (e.code == "email-already-in-use") {
          isLoadingAddPegawai.value = false;

          Get.snackbar(
            "TERJADI KESALAHAN",
            "Email telah digunakan",
          );
        } else if (e.code == "wrong-password") {
          isLoadingAddPegawai.value = false;

          Get.snackbar(
            "TERJADI KESALAHAN",
            "Admin tidak dapat login. Password salah !",
          );
        } else {
          isLoadingAddPegawai.value = false;

          Get.snackbar(
            "TERJADI KESALAHAN",
            "Kesalahan pada ${e.code} !",
          );
        }
      } catch (e) {
        isLoadingAddPegawai.value = false;

        Get.snackbar(
          "TERJADI KESALAHAN",
          "Pegawai sudah ada. Kamu tidak dapat menambhakan pegawai dengan email ini.",
        );
      }
    } else {
      isLoading.value = false;
      Get.snackbar(
          "Terjadi Kesalahan", "Password validasi tidak boleh kososng");
    }
  }
}
