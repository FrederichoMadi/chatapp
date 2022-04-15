import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:chatapp/app/utils/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Stack(
          children: [
            Material(
              color: purple,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 30, 30, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chats",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Get.toNamed(Routes.PROFILE);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.person,
                              size: 35, color: Colors.blue[900]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              margin: EdgeInsets.only(top: Get.height * 0.12),
              padding: EdgeInsets.only(top: Get.height * 0.04),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.chatsStream(authC.user.value.email!),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    var allChats = snapshot.data!.docs;
                    return ListView.builder(
                        itemCount: allChats.length,
                        itemBuilder: (contexSt, index) {
                          return allChats.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Tidak ada chat",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                                  stream: controller.friendStream(
                                      allChats[index]["connection"]),
                                  builder: ((context, snapshot2) {
                                    if (snapshot2.connectionState ==
                                        ConnectionState.active) {
                                      var data = snapshot2.data!.data();
                                      return data!.isEmpty
                                          ? const Center(
                                              child: Text(
                                                "Tidak ada chat",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                          : data['status'] != ""
                                              ? ListTile(
                                                  onTap: () {
                                                    controller.goToChatRoom(
                                                        allChats[index]
                                                            .id
                                                            .toString(),
                                                        authC.user.value.email!,
                                                        allChats[index]
                                                            ["connection"]);
                                                  },
                                                  leading: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.black26,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child:
                                                            data['photoUrl'] ==
                                                                    "noImage"
                                                                ? Image.asset(
                                                                    "assets/logo/noimage.png",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Image.network(
                                                                    data[
                                                                        'photoUrl'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                  ),
                                                  title: Text(
                                                    "${data['name']}",
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "${data['status']}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  trailing: allChats[index][
                                                              'total_unread'] ==
                                                          0
                                                      ? SizedBox()
                                                      : Chip(
                                                          backgroundColor:
                                                              Colors.red,
                                                          label: Text(
                                                            "${allChats[index]['total_unread']}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                )
                                              : ListTile(
                                                  onTap: () {
                                                    controller.goToChatRoom(
                                                        allChats[index]
                                                            .id
                                                            .toString(),
                                                        authC.user.value.email!,
                                                        allChats[index]
                                                            ["connection"]);
                                                  },
                                                  leading: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.black26,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child:
                                                            data['photoUrl'] ==
                                                                    "noImage"
                                                                ? Image.asset(
                                                                    "assets/logo/noimage.png",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Image.network(
                                                                    data[
                                                                        'photoUrl'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                  ),
                                                  title: Text(
                                                    "${data['name']}",
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  trailing: allChats[index][
                                                              'total_unread'] ==
                                                          0
                                                      ? SizedBox()
                                                      : Chip(
                                                          backgroundColor:
                                                              Colors.red,
                                                          label: Text(
                                                            "${allChats[index]['total_unread']}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                );
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  }),
                                );
                        });
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.SEARCH);
        },
        backgroundColor: purple,
        child: Icon(
          Icons.search_rounded,
          size: 30,
        ),
      ),
    );
  }
}
