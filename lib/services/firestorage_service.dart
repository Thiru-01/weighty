import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weighty/components/dialogues.dart';

//Always try to access this class using FirestoreCURDService
class FirestorageService extends WeiNotifierDelegate {
  final BuildContext context;
  FirestorageService(this.context);

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  Future<String?> uploadImage(
      {required Uint8List imageData, required String path}) async {
    if (!(await _checkImagePath(imageName: path))) {
      Reference uploadingRef = _firebaseStorage.ref();
      Reference spaceRef = uploadingRef.child(path);
      await spaceRef.putData(imageData);
      return await spaceRef.getDownloadURL();
    }
    return null;
  }

  Future<bool> _checkImagePath({required String imageName}) async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      await _firebaseStorage.ref("${user.uid}/$imageName").getData();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == "storage/object-not-found") {
        return false;
      }
    } on Exception catch (e) {
      printInfo(info: "Image is not found: $e");
      return false;
    }
    return false;
  }

  Future<void> deleteImage({required String imageUrl}) async {
    try {
      await _firebaseStorage.refFromURL(imageUrl).delete();
    } catch (e) {
      printError(info: "Unable to delete th image: $e");
    }
  }

  Future<void> deleteImageByUrl({required String url}) async {
    try {
      await _firebaseStorage.refFromURL(url).delete();
    } catch (e) {
      printError(info: "Unable to delete the image: $e");
    }
  }
}
