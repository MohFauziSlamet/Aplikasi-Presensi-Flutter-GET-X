import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  /// INISIASI FIREABASE AUTH
  FirebaseAuth auth = FirebaseAuth.instance;

  /// INISIASI FIREABASE cloud_firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// =============== CHANGE PAGE ===============
  void changePage({required int index}) async {
    switch (index) {
      case 1:
        print("ABSENSI");
        Map<String, dynamic> data = await determinePosition();

        if (data['error'] != true) {
          Position position = data['position'];

          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          // print(placemarks[0]);

          String address =
              "${placemarks[0].street} ${placemarks[0].administrativeArea} ${placemarks[0].subAdministrativeArea} , ${placemarks[0].postalCode} - ${placemarks[0].country} ${placemarks[0].isoCountryCode}";

          /// UPDATE LOCATION
          await updatePosition(position: position, address: address);

          /// MENCARI JARAK ANTARA 2 POSITION (OFFICE DAN USER )
          double distance = Geolocator.distanceBetween(
            -8.166515,
            112.4727735,
            position.latitude,
            position.longitude,
          );

          /// PRESENSI
          await presensi(
            position: position,
            address: address,
            distance: distance,
          );

          print("SELESAI");
        } else {
          Get.snackbar(
            animationDuration: Duration(seconds: 2),
            "Terjadi Kesalahan",
            "${data['message']}",
          );
        }

        break;
      case 2:
        pageIndex.value = index;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = index;
        Get.offAllNamed(Routes.HOME);
    }
  }

  /// =============== PRESENSI ===============
  Future<void> presensi({
    required Position position,
    required String address,
    required double distance,
  }) async {
    // MENGAMBIL UID
    String uid = await auth.currentUser!.uid;

    // MASUK KE FIRESTORE
    // DAN MEMBUAT NESTED COLLECTION
    CollectionReference<Map<String, dynamic>> collectionPresence =
        await firestore.collection("pegawai").doc(uid).collection("presence");

    /// CEK PERTAMA KALI BUAT COLLECTION ATAU SUDAH PERNAH
    QuerySnapshot<Map<String, dynamic>> snapshotPresence =
        await collectionPresence.get();

    /// MEMBUAT DOCUMENT ID UNTUK PRESENCE
    DateTime now = DateTime.now();
    String todayDocIdPresence =
        DateFormat.yMd().format(now).replaceAll("/", "-");

    /// MEMBUAT DEFAULT STATUS
    String status = "Di Luar Area";
    if (distance <= 200) {
      /// JIKA JARAK NYA KURANG DARI 200 METER
      /// MAKA STATUS AKAN DIUBAH MENAJADI DI DALAM AREA
      status = "Di Dalam Area";
    }

    if (snapshotPresence.docs.length == 0) {
      /// BELUM PERNAH ABSEN SAMA SEKALI, PERTAMA KALI ABSEN MASUK

      await Get.defaultDialog(
        title: "Validasi",
        middleText:
            "Apakah kamu yakin akan mengisi daftar hadir ( MASUK ) sekarang?",
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              collectionPresence.doc(todayDocIdPresence).set(
                {
                  "date": now.toIso8601String(),
                  "masuk": {
                    "date": now.toIso8601String(),
                    "lat": position.latitude,
                    "long": position.longitude,
                    "address": address,
                    "status": status,
                    "distance": distance,
                  },
                },
              );
              Get.back();
              Get.snackbar(
                "Berhasil",
                "Kamu telah mengisi daftar hadir ( MASUK )",
                animationDuration: Duration(seconds: 2),
              );
            },
            child: Text("YES"),
          ),
        ],
      );
    } else {
      /// SUDAH PERNAH ABSEN.
      /// KITA CEK TANGGAL HARI INI SUDAH ABSEN MASUK ?
      /// ATAU SUDAH ABSEN MASUK DAN KELUAR

      /// KITA CEK DATA TANGGAL HARI ADA ATAU TIDAK
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await collectionPresence.doc(todayDocIdPresence).get();

      if (todayDoc.exists == true) {
        /// IF TRUE
        /// HARI INI SUDAH ADA DATA.
        /// ARTINYA SUDAH ABSEN MASUK . ATAU SUDAH ABSEN MASUK DAN KELUAR
        /// KITA LAKUKAN CEK ABSEN KELUAR SUDAH ADA APA BELUM

        Map<String, dynamic>? dataMapPresence = todayDoc.data();
        if (dataMapPresence?['keluar'] != null) {
          /// IF TRUE
          /// SUDAH ABSEN KELUAR
          /// ARTINYA SUDAH ABSEN MASUK DAN KELUAR
          Get.snackbar(
            "Informasi Penting",
            "Kamu sudah absen masuk dan keluar. Tidak dapat mengubahnya kembali",
            animationDuration: Duration(seconds: 2),
          );
        } else {
          /// IF FALSE
          /// BELUM ABSEN KELUAR
          /// METHODE UPDATE => MENAMBAHKAN DATA ATAU MEMPERBARUI DATA YANG SUDAH ADA
          await Get.defaultDialog(
            title: "Validasi",
            middleText:
                "Apakah kamu yakin akan mengisi daftar hadir ( KELUAR ) sekarang?",
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () async {
                  collectionPresence.doc(todayDocIdPresence).update(
                    {
                      "keluar": {
                        "date": now.toIso8601String(),
                        "lat": position.latitude,
                        "long": position.longitude,
                        "address": address,
                        "status": status,
                        "distance": distance,
                      },
                    },
                  );
                  Get.back();
                  Get.snackbar(
                    "Berhasil",
                    "Kamu telah mengisi daftar hadir ( KELUAR )",
                    animationDuration: Duration(seconds: 2),
                  );
                },
                child: Text("YES"),
              ),
            ],
          );
        }
      } else {
        /// IF FALSE
        /// HARI INI BELUM ABSEN MASUK , ARTINYA JUGA BELUM ABSEN KELUAR.
        /// KITA LAKUKAN ABSEN MASUK

        /// METHODE SET => UNTUK PERTAMA KALI MEMASUKAN DATA DAN BERSIFAT MEREPLACE
        await Get.defaultDialog(
          title: "Validasi",
          middleText:
              "Apakah kamu yakin akan mengisi daftar hadir ( MASUK ) sekarang?",
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              child: Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                collectionPresence.doc(todayDocIdPresence).set(
                  {
                    "date": now.toIso8601String(),
                    "masuk": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distance,
                    },
                  },
                );
                Get.back();
                Get.snackbar(
                  "Berhasil",
                  "Kamu telah mengisi daftar hadir ( MASUK )",
                  animationDuration: Duration(seconds: 2),
                );
              },
              child: Text("YES"),
            ),
          ],
        );
      }
    }
  }

  /// =============== UPDATE POSITION ===============
  Future<void> updatePosition({
    required Position position,
    required String address,
  }) async {
    // MENGAMBIL UID
    String uid = await auth.currentUser!.uid;

    // MASUK KE FIRESTORE
    // DAN MENGUPDATE POSITION
    await firestore.collection("pegawai").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address,
    });
  }

  /// =============== GET LOCATION ===============
  // Determine the current position of the device.
  //  When the location services are not enabled or permissions
  //  are denied the `Future` will return an error.
  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return {
        "message": "Tidak dapat mengakses GPS pada device ini",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        return {
          "message": "Izin mengakses GPS ditolak.",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Settingan hp kamu tidak memperbolehkan mengakses GPS. Ubah settingan hp kamu.",
        "error": true,
      };
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device",
      "error": false,
    };
  }
}
