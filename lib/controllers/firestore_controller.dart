import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weighty/components/graph.dart';
import 'package:weighty/models/wei_model.dart';
import 'package:weighty/services/firestore_service.dart';

class FirestoreController extends GetxController {
  RxList<WeiData> storeData = <WeiData>[].obs;
  RxList<ReportDate> reportData = <ReportDate>[].obs;
  final BuildContext context;
  FirestoreController(this.context);

  Future<void> fetchData(User? user, String selectedValue) async {
    FirestoreFetcherService fetcherService = FirestoreFetcherService(context);
    if (user != null) {
      reportData.value = await fetcherService.getGraphData(
          path: user.uid, selectedFilter: selectedValue);
      //Refreshing the Rx-List
      reportData.refresh();
      storeData.value = await fetcherService.getData(
          path: user.uid, selectedFilter: selectedValue);
      storeData.refresh();
    }
  }
}
