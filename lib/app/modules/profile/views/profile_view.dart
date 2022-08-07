// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '/app/controllers/page_index_controller.dart';
import '/app/routes/app_pages.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);

  final pageC = Get.find<PageIndexController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamDataUser(),
        builder: (context, snapshot) {
          /// KONDISI WAITING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          /// CEK APAKAH ADA DATANYA
          if (snapshot.hasData) {
            Map<String, dynamic> dataUser = snapshot.data!.data()!;
            String defaultImage =
                "https://ui-avatars.com/api/?name=${dataUser['name'].toString().toLowerCase()}";

            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.network(
                          dataUser['profile'] != null &&
                                  dataUser['profile'] != ""
                              ? dataUser['profile']
                              : defaultImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  dataUser['name'].toString().toUpperCase(),
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  "${dataUser['email']}",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                /// TOMBOL UPDATE PROFILE
                ListTile(
                  onTap: () {
                    Get.toNamed(
                      Routes.UPDATE_PROFILE,
                      arguments: dataUser,
                    );
                  },
                  leading: Icon(Icons.person),
                  title: Text("Update Profile"),
                ),

                /// TOMBOL UPDATE PASSWORD
                ListTile(
                  onTap: () {
                    Get.toNamed(Routes.CHANGE_PASSWORD);
                  },
                  leading: Icon(Icons.vpn_key),
                  title: Text("Update Password"),
                ),

                /// JIKA ROLE ADMIN
                if (dataUser["role"] == "admin")
                  ListTile(
                    onTap: () {
                      Get.toNamed(Routes.ADD_PEGAWAI);
                    },
                    leading: Icon(Icons.person_add),
                    title: Text("Tambah Pegawai"),
                  ),

                /// TOMBOL UNTUK LOGOUT
                ListTile(
                  onTap: () {
                    Get.defaultDialog(
                      title: "Halo",
                      middleText: "Apakah kamu yakin mau keluar?",
                      onConfirm: () {
                        if (controller.isLoading.isFalse) {
                          controller.logOut();
                        }
                      },
                    );
                  },
                  leading: Icon(Icons.logout),
                  title: Text(
                    controller.isLoading.isFalse ? "Logout" : "Loading...",
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Text("Tidak dapat mengambil data user. Hubungi Admin"),
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
// https://ui-avatars.com/api/?name=John+Doe