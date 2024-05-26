import 'package:chat_app/model/chatroommodel.dart';
import 'package:chat_app/model/firebasehelper.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:chat_app/screens/chatroom/chatroompage.dart';
import 'package:chat_app/screens/home/custom_drawer.dart';
import 'package:chat_app/screens/auth/loginpage.dart';
import 'package:chat_app/screens/search/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel; //user ki sari detail inhi dono se milega
  final User firebaseUser;
  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 210, 139),
      appBar: AppBar(
        backgroundColor: Colors.yellow[300],
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
                onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SearchPage(
                  userModel: widget.userModel, firebaseUser: widget.firebaseUser);
            }));
            },
                icon: const Icon(Icons.search)),
          )
        ],
        automaticallyImplyLeading: true,
        centerTitle: true,
        title:const Text("Chat Sphere"),
      ),
      drawer:const CustomDrawer() ,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color.fromARGB(255, 184, 169, 37),
      //   onPressed: () {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) {
      //       return SearchPage(
      //           userModel: widget.userModel, firebaseUser: widget.firebaseUser);
      //     }));
      //   },
      //   child: Icon(Icons.search),
      // ),
      body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              
            ),
        child: StreamBuilder(
            //streamBuilder real time chages ko observe kar leta h
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;
                  //in chatRoomSnapshot me bahut sare document hoge ak nahi hoga insab ko show karane ke liye ham ListView.builder()ka use karenge
                  return ListView.builder(
                      itemCount: chatRoomSnapshot.docs.length,
                      itemBuilder: (contex, index) {
                        //ab hame targetUser ka targetUserModel chahiye jise ham usake last message aur photo aur name ko show kar sake
                        //aur userModel means logged user ka to pata h jisaka sara data widget.userModel me h
                        //ab hamlog ak targetUserModel banayege jisase usake sara data ko fetch kar sake
                        chatroomModel chatroomfortargetModel = chatroomModel
                            .fromMap(chatRoomSnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        Map<String, dynamic>? participants =
                            chatroomfortargetModel.participants;
                        List<String> participateKey =
                            participants!.keys.toList();
                        participateKey.remove(widget.userModel.uid);
                        return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participateKey[0]),
                            builder: (context, userData) {
                              UserModel targetUser = userData.data as UserModel;
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return chatRoomPage(
                                            targetModel: targetUser,
                                            chatRoom: chatroomfortargetModel,
                                            userModel: widget.userModel,
                                            firebaseUser: widget.firebaseUser);
                                      }));
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetUser.profilePic.toString()),
                                    ),
                                    title: Text(
                                      targetUser.fullName.toString(),
                                    ),
                                    subtitle: (chatroomfortargetModel
                                                .lastmessage
                                                .toString() !=
                                            "")
                                        ? Text(chatroomfortargetModel
                                            .lastmessage
                                            .toString())
                                        : Text(
                                            "Say hi to your new friend !",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                          ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            });
                      });
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.hasError.toString()),
                  );
                } else {
                  return Center(
                    child: Text("Nochat"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      )),
    );
  }
}
