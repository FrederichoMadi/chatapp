import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/utils/style.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_status_controller.dart';

class UpdateStatusView extends GetView<UpdateStatusController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    controller.statusC.text = authC.user.value.status!;
    return Scaffold(
      backgroundColor: purple,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: purple,
        title: Text('Update Status'),
        centerTitle: true,
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
        child: Column(
          children: [
            TextField(
              controller: controller.statusC,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                authC.updateStatus(controller.statusC.text);
              },
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: "Masukan status anda",
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
            Container(
              padding: const EdgeInsets.only(top: 30),
              width: Get.width,
              child: ElevatedButton(
                onPressed: () => authC.updateStatus(controller.statusC.text),
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
      ),
    );
  }
}
