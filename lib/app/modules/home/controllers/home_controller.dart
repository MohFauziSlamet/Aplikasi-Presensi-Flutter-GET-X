// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';

class HomeController extends GetxController {
  /// MENANGANI EFEK LOADING PADA BUTTON
  RxBool isLoading = false.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  /// INISIASI FIREABASE FIRESTORE
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// LOGOUT
  void logOut() async {
    isLoading.value = true; // BUTTON AKAN MENAMPILKAN LOADING
    await auth.signOut().then((value) {
      print(auth.currentUser);
    });
    isLoading.value = false; // BUTTON SELESAI LOADING
    Get.offAllNamed(Routes.LOGIN);
  }

  /// ============ STREAM DATA USER ============
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser() async* {
    /// MENGAMBIL UID DARI currentUser
    String uid = auth.currentUser!.uid;

    yield* firestore.collection("pegawai").doc(uid).snapshots();
  }

  /// ============ STREAM DATA LAST 5 PRESENCE USER ============
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLastPresence() async* {
    /// MENGAMBIL UID DARI currentUser
    String uid = auth.currentUser!.uid;

    /// MENGAMBIL DATA BERSARKAN DATE
    /// DAN MENGAMBIL 5 TERAKHIR
    yield* firestore
        .collection("pegawai")
        .doc(uid)
        .collection("presence")
        .orderBy("date")
        .limitToLast(5)
        .snapshots();
  }

  /// ============ STREAM DATA TODAY PRESENCE USER ============
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamTodayPresence() async* {
    /// MENGAMBIL UID DARI currentUser
    String uid = auth.currentUser!.uid;

    /// MEMBUAT ID TODAY
    String todayId =
        DateFormat.yMd().format(DateTime.now()).replaceAll("/", "-");

    /// MENGAMBIL DATA PRESENCE HARI INI
    yield* firestore
        .collection("pegawai")
        .doc(uid)
        .collection("presence")
        .doc(todayId)
        .snapshots();
  }
}
