import 'dart:async';
import 'dart:io';

import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/utils/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final authC = Get.find<AuthController>();
  final String chat_id = (Get.arguments as Map<String, dynamic>)["chat_id"];
  final String friendEmail =
      (Get.arguments as Map<String, dynamic>)["friend_email"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 5),
              Icon(Icons.arrow_back),
              const SizedBox(width: 5),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: StreamBuilder<DocumentSnapshot<dynamic>>(
                    stream: controller.streamFriendData(friendEmail),
                    builder: (context, snapFriendUser) {
                      if (snapFriendUser.connectionState ==
                          ConnectionState.active) {
                        var dataFriend = (snapFriendUser.data!.data())
                            as Map<String, dynamic>;
                        if (dataFriend["photoUrl"] == "noImage") {
                          return ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset("assets/logo/noimage.png"));
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              dataFriend["photoUrl"],
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      }
                      return Image.asset("assets/logo/noimage.png");
                    }),
              ),
            ],
          ),
        ),
        title: StreamBuilder<DocumentSnapshot<dynamic>>(
            stream: controller.streamFriendData(friendEmail),
            builder: (context, snapFriendUser) {
              if (snapFriendUser.connectionState == ConnectionState.active) {
                var dataFriend =
                    (snapFriendUser.data!.data()) as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataFriend["name"].toString(),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dataFriend["status"].toString(),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    )
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  )
                ],
              );
            }),
      ),
      body: WillPopScope(
        onWillPop: () {
          if (controller.isShowEmoji.isTrue) {
            controller.isShowEmoji.value = false;
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: controller.streamChats(chat_id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        var alldata = snapshot.data!.docs;
                        Timer(
                          Duration.zero,
                          () => controller.scrollC.jumpTo(
                              controller.scrollC.position.maxScrollExtent),
                        );
                        return ListView.builder(
                            controller: controller.scrollC,
                            itemCount: alldata.length,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      "${alldata[index]["groupTime"]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    itemChat(
                                      isSender: alldata[index]["pengirim"] ==
                                              authC.user.value.email!
                                          ? true
                                          : false,
                                      message: "${alldata[index]["msg"]}",
                                      time: "${alldata[index]["time"]}",
                                    ),
                                  ],
                                );
                              } else {
                                if (alldata[index]["groupTime"] ==
                                    alldata[index - 1]["groupTime"]) {
                                  return itemChat(
                                    isSender: alldata[index]["pengirim"] ==
                                            authC.user.value.email!
                                        ? true
                                        : false,
                                    message: "${alldata[index]["msg"]}",
                                    time: "${alldata[index]["time"]}",
                                  );
                                }
                              }
                              return Column(
                                children: [
                                  Text(
                                    "${alldata[index]["groupTime"]}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  itemChat(
                                    isSender: alldata[index]["pengirim"] ==
                                            authC.user.value.email!
                                        ? true
                                        : false,
                                    message: "${alldata[index]["msg"]}",
                                    time: "${alldata[index]["time"]}",
                                  ),
                                ],
                              );
                            });
                      }
                      return Center(child: CircularProgressIndicator());
                    })),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: EdgeInsets.only(
                bottom: controller.isShowEmoji.isFalse
                    ? context.mediaQueryPadding.bottom
                    : 5,
              ),
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        autocorrect: true,
                        controller: controller.chatC,
                        focusNode: controller.focusNode,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            onPressed: () {
                              controller.focusNode.unfocus();
                              controller.isShowEmoji.toggle();
                            },
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onEditingComplete: () => controller.newChat(
                            authC.user.value.email!,
                            Get.arguments as Map<String, dynamic>,
                            controller.chatC.text),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: purple,
                    borderRadius: BorderRadius.circular(100),
                    child: InkWell(
                      onTap: () => controller.newChat(
                          authC.user.value.email!,
                          Get.arguments as Map<String, dynamic>,
                          controller.chatC.text),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          Icons.send_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Obx(() => controller.isShowEmoji.isTrue
                ? Expanded(
                    child: Container(
                      height: 325,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          // Do something when emoji is tapped
                          controller.addEmojiToChat(emoji);
                        },
                        onBackspacePressed: () {
                          // Backspace-Button tapped logic
                          // Remove this line to also remove the button in the UI
                          controller.deleteEmoji();
                        },
                        config: Config(
                            columns: 7,
                            emojiSizeMax: 32 *
                                (Platform.isIOS
                                    ? 1.30
                                    : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            initCategory: Category.RECENT,
                            bgColor: Color(0xFFF2F2F2),
                            indicatorColor: purple,
                            iconColor: Colors.grey,
                            iconColorSelected: purple,
                            progressIndicatorColor: purple,
                            backspaceColor: purple,
                            skinToneDialogBgColor: Colors.white,
                            skinToneIndicatorColor: Colors.grey,
                            enableSkinTones: true,
                            showRecentsTab: true,
                            recentsLimit: 28,
                            noRecentsText: "No Recents",
                            noRecentsStyle: const TextStyle(
                                fontSize: 20, color: Colors.black26),
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: const CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL),
                      ),
                    ),
                  )
                : SizedBox()),
          ],
        ),
      ),
    );
  }
}

class itemChat extends StatelessWidget {
  itemChat({
    required this.isSender,
    required this.message,
    required this.time,
  });
  final bool isSender;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: purple.withOpacity(0.9),
              borderRadius: isSender
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
            ),
            padding: const EdgeInsets.all(15),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat.jm().format(DateTime.parse(time)).toString(),
          ),
        ],
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
