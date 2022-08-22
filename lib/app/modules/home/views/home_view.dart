// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/controllers/page_index_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final pageC = Get.find<PageIndexController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamUser(),
        builder: (context, snapshot) {
          /// WAITING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          /// PUNYA DATA
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!.data()!;
            print("cek ${data}");
            String defaultImage =
                "https://ui-avatars.com/api/?name=${data['name'].toString().toLowerCase()}";
            // String location =
            //     "Latitude ${data['position']['lat']} - Longtitude ${data['position']['long']}";
            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                /// INFORMASI FOTO PROFIL DAN DATA PEGAWAI
                Row(
                  children: [
                    /// FOTO PROFIL
                    ClipOval(
                      child: Container(
                        height: 75,
                        width: 75,
                        color: Colors.grey[200],
                        child: Image.network(
                          data['profile'] ?? defaultImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WELCOME",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(height: 5),
                        SizedBox(
                          width: 230,
                          child: Text(
                            data['address'] ?? "Belum ada lokasi",
                            maxLines: 3,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 20),

                /// CARD NAMA
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['job'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        data['nip'],
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        data['name'],
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                /// MASUK KELUAR
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: controller.streamTodayPresence(),
                    builder: (context, snapshotTodayPresence) {
                      /// KONDISI WAITING
                      if (snapshotTodayPresence.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      /// ADA DATA

                      Map<String, dynamic>? data =
                          snapshotTodayPresence.data?.data();

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text("Masuk"),
                              SizedBox(height: 5),
                              Text(
                                data?['masuk']?['date'] == null
                                    ? "---"
                                    : DateFormat.jms().format(
                                        DateTime.parse(data?['masuk']['date'])),
                              ),
                            ],
                          ),
                          Container(
                            height: 40,
                            width: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                          ),
                          Column(
                            children: [
                              Text("Keluar"),
                              SizedBox(height: 5),
                              Text(
                                data?['keluar']?['date'] == null
                                    ? "---"
                                    : DateFormat.jms().format(DateTime.parse(
                                        data?['keluar']['date'])),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),

                /// GARIS BATAS
                SizedBox(height: 20),
                Divider(
                  color: Colors.grey[300],
                  thickness: 2,
                ),

                /// INFO LAST ABSENSI
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Last 5 Days",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(Routes.ALL_PRESENSI);
                      },
                      child: Text(
                        "See more",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),

                /// INFO ABSENSI
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.streamLastPresence(),
                  builder: (context, snapshotPresnece) {
                    /// KONDISI WAITING
                    if (snapshotPresnece.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    /// TIDAK ADA DATA
                    if (snapshotPresnece.data?.docs.length == 0 ||
                        snapshotPresnece.data == null) {
                      return Container(
                        height: 150,
                        margin: EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            "Belum ada data presensi",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    }

                    /// ADA DATA
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshotPresnece.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = snapshotPresnece
                            .data!.docs.reversed
                            .toList()[index]
                            .data();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Material(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(
                                  Routes.DETAIL_PRESENSI,
                                  arguments: data,
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Masuk",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        /// TANGGAL PRESENCE
                                        Text(
                                          DateFormat.yMMMEd().format(
                                            DateTime.parse(
                                              data['date'],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    /// JAM MASUK
                                    Text(
                                      data['masuk']?['date'] == null
                                          ? "-"
                                          : DateFormat.jms().format(
                                              DateTime.parse(
                                                  data['masuk']!['date'])),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Keluar",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    /// JAM KELUAR
                                    Text(
                                      data['keluar']?['date'] == null
                                          ? "-"
                                          : DateFormat.jms().format(
                                              DateTime.parse(
                                                data['keluar']!['date'],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            );
          } else {
            return Center(
              child: Text("Tidak dapat memuat database user"),
            );
          }
        },
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.fingerprint, title: 'Finger'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value, //optional, default as 0
        onTap: (int i) => pageC.changePage(index: i),
      ),
    );
  }
}
