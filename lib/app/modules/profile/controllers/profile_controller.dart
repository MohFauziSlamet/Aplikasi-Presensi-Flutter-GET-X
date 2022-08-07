import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  /// MENANGANI EFEK LOADING PADA BUTTON
  RxBool isLoading = false.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  /// INISIASI FIREABASE FIRESTORE
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// STREAM ROLE
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDataUser() async* {
    /// MENGAMBIL UID DARI currentUser
    String uid = auth.currentUser!.uid;

    yield* firestore.collection("pegawai").doc(uid).snapshots();
  }

  /// LOGOUT
  void logOut() async {
    isLoading.value = true; // BUTTON AKAN MENAMPILKAN LOADING
    await auth.signOut().then((value) {
      print(auth.currentUser);
    });
    isLoading.value = false; // BUTTON SELESAI LOADING
    Get.offAllNamed(Routes.LOGIN);
  }
}
