import 'package:chatapp/app/data/models/users_model.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  var isSkpiIntro = false.obs;
  var isAuth = false.obs;

  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? _userCredential;

  var user = UsersModel().obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> firstInitial() async {
    await autoLogin().then((value) {
      if (value) {
        isAuth.value = true;
      }
    });

    await skipIntro().then((value) {
      if (value) {
        isSkpiIntro.value = true;
      }
    });
  }

  Future<bool> skipIntro() async {
    // kita akan mengubah isSkipIntro => true
    final box = GetStorage();
    if (box.read("skipIntro") != null || box.read("skipIntro") == true) {
      return true;
    }
    return false;
  }

  Future<bool> autoLogin() async {
    // kita akan mengubah isAuth => true
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        await _googleSignIn
            .signInSilently()
            .then((value) => _currentUser = value);

        final googleAuth = await _currentUser!.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => _userCredential = value);

        //masukan data ke firestore
        final users = firestore.collection("users");

        await users.doc(_currentUser!.email).update({
          "lastSignInTime":
              _userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
        });

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat['lastTime'],
                totalUnread: dataDocChat["total_unread"]));
          });

          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        user.refresh();

        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> login() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.signIn().then((value) => _currentUser = value);

      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        print("Sudah Berhasil Login");
        print(_currentUser);

        final googleAuth = await _currentUser!.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => _userCredential = value);

        print("USER CREDENTIAL");
        print(_userCredential);

        final box = GetStorage();
        if (box.read("skipIntro") != null) {
          box.remove("skipIntro");
        }
        box.write("skipIntro", true);

        //masukan data ke firestore
        final users = firestore.collection("users");

        final checkUser = await users.doc(_currentUser!.email).get();

        if (checkUser.data() == null) {
          await users.doc(_currentUser!.email).set({
            "uid": _userCredential!.user!.uid,
            "name": _currentUser!.displayName,
            "email": _currentUser!.email,
            "keyName": _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            "photoUrl": _currentUser!.photoUrl ?? "noImage",
            "status": "",
            "creationTime":
                _userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": _userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updateTime": DateTime.now().toIso8601String(),
          });

          users.doc(_currentUser!.email).collection("chats");
        } else {
          await users.doc(_currentUser!.email).update({
            "lastSignInTime": _userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        // TODO : Fixing list collectin chats user
        user(UsersModel.fromJson(currUserData));

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat['lastTime'],
                totalUnread: dataDocChat["total_unread"]));
          });

          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        user.refresh();

        isAuth.value = true;
        print("pindah halaman dong");
        Get.offAllNamed(Routes.HOME);
      } else {
        print("Tidak Berhasil Login");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    // await _googleSignIn.disconnect();
    Get.offAllNamed(Routes.LOGIN);
  }

  void changeProfile(String name, String status) {
    String date = DateTime.now().toIso8601String();

    //update firebase
    CollectionReference users = firestore.collection("users");

    users.doc(_currentUser!.email).update({
      "name": name,
      "status": status,
      "lastSIgnInTimew":
          _userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updateAt": date,
    });

    //update model
    user.update((user) {
      user!.name = name;
      user.status = status;
      user.lastSignInTime =
          _userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updatedTime = date;
    });

    user.refresh();
    Get.defaultDialog(title: "Success", middleText: "Change profile success");
  }

  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();

    //update firebase
    CollectionReference users = firestore.collection("users");

    users.doc(_currentUser!.email).update({
      "status": status,
      "lastSIgnInTimew":
          _userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updateAt": date,
    });

    //update model
    user.update((user) {
      user!.status = status;
      user.lastSignInTime =
          _userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user.updatedTime = date;
    });

    user.refresh();
    Get.defaultDialog(title: "Success", middleText: "Update status success");
  }

  void updatePhotoUrl(String url) async {
    String date = DateTime.now().toIso8601String();

    //update firebase
    CollectionReference users = firestore.collection("users");

    await users.doc(_currentUser!.email).update({
      "photoUrl": url,
      "updateAt": date,
    });

    //update model
    user.update((user) {
      user!.photoUrl = url;

      user.updatedTime = date;
    });

    user.refresh();
    Get.defaultDialog(
        title: "Success", middleText: "Change photo profile success");
  }

  void addNewConnection(String email) async {
    bool flagNewConnection = false;
    var chat_id;
    var date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    final docChats =
        await users.doc(_currentUser!.email).collection("chats").get();

    if (docChats.docs.length != 0) {
      // user sudah pernah chat
      final chechkConnection = await users
          .doc(_currentUser!.email)
          .collection("chats")
          .where("connection", isEqualTo: email)
          .get();

      if (chechkConnection.docs.length != 0) {
        flagNewConnection = false;
        chat_id = chechkConnection.docs[0].id;
      } else {
        flagNewConnection = true;
      }
    } else {
      // user belum pernah chat
      flagNewConnection = true;
    }

    if (flagNewConnection) {
      // check from chats collection => connections => other user..
      final chatsDocs = await chats.where("connections", whereIn: [
        [_currentUser?.email, email],
        [email, _currentUser?.email]
      ]).get();

      if (chatsDocs.docs.isNotEmpty) {
        // data is not empty
        var chatDocsId = chatsDocs.docs[0].id;
        final chatData = chatsDocs.docs[0].data() as Map<String, dynamic>;

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(chatDocsId)
            .set({
          "connection": email,
          "lastTime": chatData['lastTime'],
          "total_unread": 0,
        });

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          var dataListChats = List<ChatUser>.empty();
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat['lastTime'],
                totalUnread: dataDocChat["total_unread"]));
          });

          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        await users.doc(_currentUser!.email).update({
          "chats": docChats,
        });

        user.update((value) {
          value?.chats = docChats as List<ChatUser>;
        });

        chat_id = chatDocsId;
        user.refresh();
      } else {
        var newChatDoc = await chats.add({
          "connections": [_currentUser?.email, email],
        });

        await chats.doc(newChatDoc.id).collection("chat");

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(newChatDoc.id)
            .set({
          "connection": email,
          "lastTime": date,
          "total_unread": 0,
        });

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatUser> dataListChats = [];
          listChats.docs.toList().forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat['lastTime'],
                totalUnread: dataDocChat["total_unread"]));
          });

          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        chat_id = newChatDoc.id;
        user.refresh();
      }
    }

    final updateStatusChat = await chats
        .doc(chat_id)
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("penerima", isEqualTo: _currentUser!.email)
        .get();

    updateStatusChat.docs.forEach((element) async {
      await chats
          .doc(chat_id)
          .collection("chat")
          .doc(element.id)
          .update({"isRead": true});
    });

    Get.toNamed(Routes.CHAT_ROOM, arguments: {
      "chat_id": chat_id,
      "friend_email": email,
    });
  }
}
