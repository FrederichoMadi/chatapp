import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatRoomController extends GetxController {
  var isShowEmoji = false.obs;
  late FocusNode focusNode;
  late TextEditingController chatC;
  int total_unread = 0;

  late ScrollController scrollC;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<dynamic>> streamFriendData(String friendEmail) {
    CollectionReference users = firestore.collection("users");

    return users.doc(friendEmail).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamChats(String chat_id) {
    CollectionReference chats = firestore.collection("chats");

    return chats.doc(chat_id).collection("chat").orderBy("time").snapshots();
  }

  @override
  void onInit() {
    focusNode = FocusNode();
    chatC = TextEditingController();
    scrollC = ScrollController();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isShowEmoji.value = false;
      }
    });
    super.onInit();
  }

  void addEmojiToChat(Emoji emoji) {
    chatC.text = chatC.text + emoji.emoji;
  }

  void deleteEmoji() {
    chatC.text = chatC.text.characters.skipLast(1).toString();
    chatC.selection =
        TextSelection.fromPosition(TextPosition(offset: chatC.text.length));
  }

  void newChat(
      String email, Map<String, dynamic> arguments, String chat) async {
    if (chat != "") {
      CollectionReference chats = firestore.collection("chats");
      CollectionReference users = firestore.collection("users");
      String date = DateTime.now().toIso8601String();

      await chats.doc(arguments["chat_id"]).collection("chat").add({
        "pengirim": email,
        "penerima": arguments["friend_email"],
        "msg": chat,
        "time": date,
        "isRead": false,
        "groupTime": DateFormat.yMMMd('en_US').format(DateTime.parse(date)),
      });

      Timer(
        Duration.zero,
        () => scrollC.jumpTo(scrollC.position.maxScrollExtent),
      );

      chatC.clear();

      await users
          .doc(email)
          .collection("chats")
          .doc(arguments["chat_id"])
          .update({
        "lastTime": date,
      });

      final checkChatToFriend = await users
          .doc(arguments["friend_email"])
          .collection("chats")
          .doc(arguments["chat_id"])
          .get();

      if (checkChatToFriend.exists) {
        var checkTotalUnread = await chats
            .doc(arguments["chat_id"])
            .collection("chat")
            .where("isRead", isEqualTo: false)
            .where("pengirim", isEqualTo: email)
            .get();

        total_unread = checkTotalUnread.docs.length;

        // update
        await users
            .doc(arguments["friend_email"])
            .collection("chats")
            .doc(arguments["chat_id"])
            .update({
          "lastTime": date,
          "total_unread": total_unread,
        });
      } else {
        // new for friend database
        await users
            .doc(arguments["friend_email"])
            .collection("chats")
            .doc(arguments["chat_id"])
            .set({
          "connection": email,
          "lastTime": date,
          "total_unread": 1,
        });
      }
    }
  }

  @override
  void onClose() {
    focusNode.dispose();
    chatC.dispose();
    scrollC.dispose();
    super.onClose();
  }
}
