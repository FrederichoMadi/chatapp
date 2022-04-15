import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:chatapp/app/utils/style.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purple,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            onPressed: () => authC.logout(),
            icon: Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Column(
              children: [
                Obx(() {
                  return AvatarGlow(
                    endRadius: 110,
                    duration: const Duration(seconds: 2),
                    child: Container(
                      margin: EdgeInsets.all(15),
                      width: 175,
                      height: 175,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(100),
                      ),
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
                Obx(() {
                  return Text(
                    "${authC.user.value.name}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
                Text(
                  "${authC.user.value.email}",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Get.toNamed(Routes.UPDATE_STATUS);
                    },
                    leading: const Icon(
                      Icons.note_add_outlined,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Update status",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_right_alt_rounded,
                      color: Colors.white,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.toNamed(Routes.CHANGE_PROFILE);
                    },
                    leading: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Change Profile ",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_right_alt_rounded,
                      color: Colors.white,
                    ),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: const Icon(
                      Icons.color_lens,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Change Theme",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    trailing: const Text(
                      "Light",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(bottom: context.mediaQueryPadding.bottom + 40),
            child: Column(
              children: const [
                Text(
                  "Chat App",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  "v.1.0",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
