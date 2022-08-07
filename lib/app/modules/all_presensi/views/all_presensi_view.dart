// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';

import '../controllers/all_presensi_controller.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AllPresensiView extends GetView<AllPresensiController> {
  const AllPresensiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semua Presensi'),
        centerTitle: true,
      ),
      body: GetBuilder<AllPresensiController>(
        builder: (c) {
          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: controller.getAllPresence(),
            builder: (context, snapshot) {
              /// KONDISI WAITING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              /// TIDAK ADA DATA
              if (snapshot.data?.docs.length == 0 || snapshot.data == null) {
                return Center(
                  child: Text(
                    "Belum ada data presensi",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data =
                      snapshot.data!.docs.reversed.toList()[index].data();
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
                                        DateTime.parse(data['masuk']!['date'])),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(
            Dialog(
              child: Container(
                height: 400,
                padding: EdgeInsets.all(20),
                child: SfDateRangePicker(
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                  ),
                  selectionMode: DateRangePickerSelectionMode.range,
                  showActionButtons: true,
                  onCancel: () => Get.back(),
                  onSubmit: (object) {
                    if (object != null) {
                      if ((object as PickerDateRange).endDate != null) {
                        controller.getPickDate(
                          pickEnd: object.endDate!,
                          pickStart: object.startDate!,
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          );
        },
        child: Icon(Icons.format_list_bulleted_outlined),
      ),
    );
  }
}
