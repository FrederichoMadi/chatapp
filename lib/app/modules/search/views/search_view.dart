import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:chatapp/app/utils/style.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140),
        child: AppBar(
          backgroundColor: purple,
          title: Text('Search'),
          centerTitle: true,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                onChanged: (value) {
                  controller.searchFriend(value, authC.user.value.email!);
                },
                controller: controller.searchC,
                cursorColor: purple,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: purple,
                      width: 1,
                    ),
                  ),
                  hintText: "Search new friend",
                  suffixIcon: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      color: purple,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.tempSearch.isEmpty
            ? Center(
                child: Container(
                    width: Get.width * 0.7,
                    height: Get.height * 0.7,
                    child: Lottie.asset("assets/lottie/empty.json")),
              )
            : ListView.builder(
                padding: EdgeInsets.only(top: 8),
                itemCount: controller.tempSearch.length,
                itemBuilder: (contexSt, index) {
                  return ListTile(
                    leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black26,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: controller.tempSearch[index]['photoUrl'] ==
                                  "noImage"
                              ? Image.asset(
                                  "assets/logo/noimage.png",
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  controller.tempSearch[index]['photoUrl'],
                                  fit: BoxFit.cover,
                                ),
                        )),
                    title: Text(
                      "${controller.tempSearch[index]["name"]}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${controller.tempSearch[index]["email"]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        authC.addNewConnection(
                            controller.tempSearch[index]["email"]);
                      },
                      child: Chip(
                        label: Text("Message"),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
