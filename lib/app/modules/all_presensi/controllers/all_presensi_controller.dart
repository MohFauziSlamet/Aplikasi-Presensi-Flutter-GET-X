import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AllPresensiController extends GetxController {
  DateTime? start;
  DateTime end = DateTime.now();

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  /// INISIASI FIREABASE FIRESTORE
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// ============ STREAM DATA LAST 5 PRESENCE USER ============
  Future<QuerySnapshot<Map<String, dynamic>>> getAllPresence() async {
    /// MENGAMBIL UID DARI currentUser
    String uid = auth.currentUser!.uid;

    /// MENGAMBIL DATA BERDASARKAN DATE
    if (start == null) {
      /// INI SECARA DEFAULT
      /// TIDAK ADA TANGGAL MULAI
      /// MENGAMIBL SEMUA DATA PRESENCE
      return await firestore
          .collection("pegawai")
          .doc(uid)
          .collection("presence")
          .where("date", isLessThan: end.toIso8601String())
          .orderBy("date")
          .get();
    } else {
      /// MENGAMBIL BERDASARKAN RENTAN TANGGAL TERPILIH
      return await firestore
          .collection("pegawai")
          .doc(uid)
          .collection("presence")
          .where("date", isGreaterThan: start!.toIso8601String())
          .where("date",
              isLessThan: end.add(Duration(days: 1)).toIso8601String())
          .orderBy("date")
          .get();
    }
  }

  void getPickDate({
    required DateTime pickStart,
    required DateTime pickEnd,
  }) {
    start = pickStart;
    end = pickEnd;

    update();
    Get.back();
  }
}
