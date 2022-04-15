import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../utils/style.dart';
import '../controllers/change_profile_controller.dart';

class ChangeProfileView extends GetView<ChangeProfileController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    controller.emailC.text = authC.user.value.email.toString();
    controller.nameC.text = authC.user.value.name.toString();
    controller.statusC.text = authC.user.value.status.toString();

    return Scaffold(
        backgroundColor: purple,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: purple,
          title: Text('Change Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                authC.changeProfile(
                    controller.nameC.text, controller.statusC.text);
              },
              icon: Icon(Icons.save),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              )),
          child: ListView(
            children: [
              Obx(() {
                return AvatarGlow(
                  endRadius: 75,
                  duration: const Duration(seconds: 2),
                  child: Container(
                    margin: EdgeInsets.all(15),
                    width: 125,
                    height: 125,
                    child: authC.user.value.photoUrl == "noImage"
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.asset(
                              "assets/logo/noimage.png",
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.network(
                              "${authC.user.value.photoUrl}",
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              TextField(
                controller: controller.emailC,
                readOnly: true,
                textInputAction: TextInputAction.next,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  label: Text("Email"),
                  labelStyle: TextStyle(color: purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: purple),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.nameC,
                textInputAction: TextInputAction.next,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  label: Text("Name"),
                  labelStyle: TextStyle(color: purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: purple),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.statusC,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  authC.changeProfile(
                      controller.nameC.text, controller.statusC.text);
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  label: Text("Status"),
                  labelStyle: TextStyle(color: purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: purple),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetBuilder<ChangeProfileController>(
                      builder: (c) => c.selectedImage != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 125,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        image: DecorationImage(
                                            image: FileImage(
                                              File(c.selectedImage!.path),
                                            ),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -5,
                                      child: IconButton(
                                        onPressed: () => c.resetImage(),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () => controller
                                      .uploadImage(authC.user.value.uid!)
                                      .then((value) {
                                    if (value != null) {
                                      authC.updatePhotoUrl(value);
                                    }
                                  }),
                                  child: const Text(
                                    "Upload",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          : const Text("no image"),
                    ),
                    TextButton(
                      onPressed: () => controller.pickImage(),
                      child: Text(
                        "chosen...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(top: 30),
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () {
                    authC.changeProfile(
                        controller.nameC.text, controller.statusC.text);
                  },
                  child: const Text(
                    "UPDATE",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
