import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weighty/components/dialogues.dart';
import 'package:weighty/components/graph.dart';
import 'package:weighty/models/wei_model.dart';
import 'package:weighty/services/firestorage_service.dart';
import 'package:weighty/utils/utils.dart';

class FirestoreCURDService extends WeiNotifierDelegate
    implements CURD<WeiData> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BuildContext context;
  final User? user = FirebaseAuth.instance.currentUser;
  late final FirestorageService _firestorageService;
  FirestoreCURDService(this.context) {
    _firestorageService = FirestorageService(context);
  }
  Future<void> uploadDetails(WeiData data, Uint8List? imageData,
      [String? fileExtension]) async {
    //Initialize the file uploading process
    if (user != null) {
      notifiers.openDialogues(
          context: context,
          dialogueType: DialogueType.LOADING,
          dialogueMessage: "Uploading the content into cloud...");
      try {
        DateTime weiDate = DateFormat("dd/MM/yyyy").parse(data.date);
        String path =
            "${user!.uid}/${DateFormat("dd-MM-yyyy").format(weiDate)}.${fileExtension ?? "jpg"}";
        //Uploading image to the firebase storage if imageData is not found then it skip the uploading process
        String? downloadUrl;
        if (imageData != null && imageData.isNotEmpty) {
          downloadUrl = await _firestorageService.uploadImage(
              imageData: imageData, path: path);
        }
        //Checking that there is a
        if (downloadUrl != null) {
          data.setDownloadUrl(downloadUrl: downloadUrl);
          await add(data: data, path: user!.uid);
        } else {
          await add(data: data, path: user!.uid);
          printInfo(info: "Image is not provided");
        }
      } catch (e) {
        printError(info: e.toString());
        if (context.mounted) {
          notifiers.openSnackBar(
              context: context,
              snackType: DialogueType.ERROR,
              snackMessage: "Unable to save the details, something went wrong");
        }
      }
      if (context.mounted) notifiers.closeDialogue(context: context);
    }
  }

  @override
  Future<void> add({required WeiData data, required String path}) async {
    try {
      DateTime weiDate = DateFormat("dd/MM/yyyy").parse(data.date);
      String currentWeek =
          "${BasicUtils.calculateWeekOfYear(weiDate)}-${weiDate.year}";
      DocumentReference userDocRef =
          _firestore.collection(path).doc(currentWeek);
      await userDocRef.set(data.toJson());
      //Showing the success snackbar
      if (context.mounted) {
        notifiers.openSnackBar(
            context: context, snackMessage: "Record successfully added");
      }
    } catch (e) {
      printError(info: e.toString());
      if (context.mounted) {
        notifiers.openSnackBar(
            context: context,
            snackType: DialogueType.ERROR,
            snackMessage: "Unable to add record");
      }
    }
  }

  @override
  Future<void> delete({required String path}) async {
    notifiers.openDialogues(
        context: context,
        dialogueType: DialogueType.LOADING,
        dialogueMessage: "Deleting record...");
    try {
      //Have to delete the image from
      WeiData? currentData = await get(path: path);
      if (currentData != null && user != null) {
        DateTime date = DateFormat("dd/MM/yyyy").parse(currentData.date);
        await _firestorageService.deleteImage(
            imageUrl:
                "${user!.uid}/${BasicUtils.calculateWeekOfYear(date)}-${date.year}");
        printInfo(info: "Image deleted successfully");
      }
      await _firestore.doc(path).delete();
      //Showing the success snackbar
      if (context.mounted) {
        notifiers.openSnackBar(
            context: context, snackMessage: "Record successfully deleted");
      }
    } catch (e) {
      printError(info: e.toString());
      if (context.mounted) {
        notifiers.openSnackBar(
            context: context,
            snackType: DialogueType.ERROR,
            snackMessage: "Unable to delete the record");
      }
    }
    if (context.mounted) notifiers.closeDialogue(context: context);
  }

  @override
  Future<WeiData?> get({required String path}) async {
    try {
      DocumentReference<WeiData> docRef =
          _firestore.doc(path).withConverter<WeiData>(
                fromFirestore: (snapshot, options) =>
                    WeiData.fromJson(snapshot.data()!),
                toFirestore: (value, options) => value.toJson(),
              );
      return (await docRef.get()).data();
    } catch (e) {
      printError(info: e.toString());
      if (context.mounted) {
        notifiers.openSnackBar(
            context: context,
            snackType: DialogueType.ERROR,
            snackMessage: "Unable to fetch the data");
      }
    }
    //In the case of error
    return null;
  }

  @override
  Future<void> update(
      {required Map<String, dynamic> data, required String path}) async {
    try {
      await _firestore.doc(path).update(data);
      //Showing the success snackbar
      if (context.mounted) {
        notifiers.openSnackBar(
            context: context, snackMessage: "Record successfully updated");
      }
    } catch (e) {
      printError(info: e.toString());
      if (context.mounted) {
        notifiers.openSnackBar(
            context: context,
            snackType: DialogueType.ERROR,
            snackMessage: "Unable to update the record");
      }
    }
  }

  //Document ID
  @override
  Future<List<WeiData>> getFilteredContent(
      {required String path,
      required List<String> filter,
      required String filterField}) async {
    QuerySnapshot<WeiData> queryResult = await _firestore
        .collection(path)
        .where(FieldPath.documentId, whereIn: filter)
        .withConverter<WeiData>(
            fromFirestore: (snapshot, options) =>
                WeiData.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson())
        .get();

    return queryResult.docs.map((e) => e.data()).toList();
  }

  @override
  Future<List<WeiData>> getAllData({required String path}) async {
    Query<WeiData> queryResult = _firestore
        .collection(path)
        .where(FieldPath.documentId, isNotEqualTo: "")
        .withConverter<WeiData>(
            fromFirestore: (snapshot, options) =>
                WeiData.fromJson(snapshot.data()!),
            toFirestore: (value, options) => value.toJson());
    return (await queryResult.get()).docs.map((e) => e.data()).toList();
  }
}

abstract class CURD<T> {
  Future<void> add({required T data, required String path});
  Future<void> update(
      {required Map<String, dynamic> data, required String path});
  Future<void> delete({required String path});
  Future<T?> get({required String path});
  Future<List<T?>> getAllData({required String path});
  Future<List<T>> getFilteredContent(
      {required String path,
      required List<String> filter,
      required String filterField});
}

class FirestoreFetcherService extends FirestoreCURDService {
  FirestoreFetcherService(super.context);

  Future<List<WeiData>> getData(
      {required String path, required String selectedFilter}) async {
    if (selectedFilter == "All") {
      return await getAllData(path: path);
    } else {
      return await getFilteredContent(
          path: path,
          filter: _getListOfFilterDate(selectedFilter),
          filterField: "documentId");
    }
  }

  Future<List<ReportDate>> getGraphData(
      {required String path, required String selectedFilter}) async {
    List<ReportDate> result = [];
    List<WeiData> filterData =
        await getData(path: path, selectedFilter: selectedFilter);
    for (WeiData data in filterData) {
      result.add(ReportDate(
          BasicUtils.calculateWeekOfYear(
              DateFormat("dd/MM/yyyy").parse(data.date)),
          double.tryParse(data.weight)));
    }
    return result;
  }

  List<String> _getListOfFilterDate(String filter) {
    List<String> result = [];
    DateTime currentate = DateTime.now();
    //By default it will take the last month
    DateTime startDate = DateTime(currentate.year, currentate.month - 1, 1);
    switch (filter) {
      case "Last Month":
        startDate = DateTime(currentate.year, currentate.month - 1, 1);
        break;
      case "Last 3 Month":
        startDate = DateTime(currentate.year, currentate.month - 3, 1);
        break;
      case "Last 6 Month":
        startDate = DateTime(currentate.year, currentate.month - 6, 1);
        break;
    }
    while (startDate.isBefore(currentate)) {
      result.add(
          "${BasicUtils.calculateWeekOfYear(startDate)}-${startDate.year}");
      startDate = startDate.add(const Duration(days: 7));
    }
    return result;
  }
}
