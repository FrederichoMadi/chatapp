import 'dart:io';

import 'package:chatapp/app/utils/style.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProfileController extends GetxController {
  late TextEditingController emailC;
  late TextEditingController nameC;
  late TextEditingController statusC;

  late ImagePicker imagePicker;
  XFile? selectedImage;

  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void onInit() {
    emailC = TextEditingController();
    nameC = TextEditingController();
    statusC = TextEditingController();
    imagePicker = ImagePicker();
    super.onInit();
  }

  Future<String?> uploadImage(String uid) async {
    Reference storageRef = storage.ref("$uid.png");
    File file = File(selectedImage!.path);

    try {
      storageRef.putFile(file);
      final photoUrl = await storageRef.getDownloadURL();
      resetImage();
      return photoUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void resetImage() {
    selectedImage = null;
    update();
  }

  void pickImage() async {
    try {
      final XFile? dataImage =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (dataImage != null) {
        selectedImage = dataImage;
      }
    } catch (e) {
      print(e);
    }
    update();
  }

  @override
  void onClose() {
    emailC.dispose();
    nameC.dispose();
    statusC.dispose();
    super.onClose();
  }
}
