import 'package:chat_app/main.dart';
import 'package:chat_app/model/chatroommodel.dart';
import 'package:chat_app/model/messagemodel.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class chatRoomPage extends StatefulWidget {
  final UserModel targetModel; //jisase bat karani h means dusara user(targetUser)
  final chatroomModel chatRoom;
  final UserModel userModel; //for currentuser ka userModel(loggindUser) (firebase aur userModel dono same h)
  final User firebaseUser; //firebase ka user
  const chatRoomPage(
      {Key? key,
      required this.targetModel,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  State<chatRoomPage> createState() => _chatRoomPageState();
}

class _chatRoomPageState extends State<chatRoomPage> {
  // String? formattedTime;

  // @override
  // void initState() {
  //   super.initState();
  //   formattedTime = DateFormat('hh:mm a').format(DateTime.now());
  // }
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController
        .clear(); //isase hoga ki TextField me jo write karate h send ke option per click karate h message vaha se clear ho jayega(The input method toggled text monitoring off)
    if (msg != null) {
      //send message
      messageModel newmessage = messageModel(
          messageId: uid1.v1(),
          sender: widget.userModel.uid,
          createdOn: DateTime.now(),
          text: msg,
          seen:
              false //seen tab tak false rahega jab tak samane vala message seen na kar le
          );
      //here ham await isliye use nahi kiye ki hame massage immediate send karana h n ki kuch time me
      //FirebaseFirestore hamara offline storage bhi support karata h incase hamara internet nahi chal raha
      //uscase ye message hamare divice per store ho jayega aur jaise hi hamara internet start hogi tab ye message
      //hamare cloud ke sath sink ho jayega aur dusare user tak pahuch jayega
      //await lagane se jab tak hamara message cloud tak nahi pahuch jayega tab tak hamara code ruk jayega
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomId)
          .collection("messages")
          .doc(newmessage.messageId)
          .set(newmessage.toMap());

      //update lastmessage
      widget.chatRoom.lastmessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomId)
          .set(widget.chatRoom.toMap());
      print("message send");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.yellow[300],
      appBar: AppBar(
        backgroundColor: Colors.yellow[300],
          title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            backgroundImage: NetworkImage(widget.targetModel.profilePic
                .toString()), //NetworkImage isliye use karate h ki kyoki here hame url pata h image ka
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.targetModel.fullName.toString())
        ],
      )),
      body: Container(
        decoration:const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chatbackground.png'),
            fit: BoxFit.cover
            )
        ),
        child: SafeArea(
            child: Column(
              children: [
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("chatrooms")
                          .doc(widget.chatRoom.chatroomId)
                          .collection('messages')
                          .orderBy("createdOn", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot datasnapshot =
                                snapshot.data as QuerySnapshot;
                            return ListView.builder(
                                reverse: true,
                                itemCount: datasnapshot.docs.length,
                                itemBuilder: (context, index) {
                                  messageModel currentmessage = messageModel
                                      .fromMap(datasnapshot.docs[index].data()
                                          as Map<String, dynamic>);
                                  return Column(
                                    crossAxisAlignment: (currentmessage.sender ==
                                            widget.userModel.uid)
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          constraints:const BoxConstraints(
                                            maxWidth:270,
                                            minWidth: 50,
                                          ),
                                          padding:const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          margin:const EdgeInsets.symmetric(vertical: 2),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              currentmessage.sender == widget.userModel.uid ?
                                              const BorderRadius.only(
                                                topLeft:Radius.circular(15),
                                                bottomLeft:Radius.circular(15),
                                                bottomRight:Radius.circular(15),
                                                ):
                                               const BorderRadius.only(
                                                topRight:Radius.circular(15),
                                                bottomRight:Radius.circular(15),
                                                bottomLeft:Radius.circular(15),
                                                ),
                                              color: (currentmessage.sender ==
                                                      widget.userModel.uid)
                                                  ? const Color.fromARGB(255, 11, 111, 98)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .secondary),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  style:const TextStyle(color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                  currentmessage.text.toString()),
                                              // Align(
                                              //   alignment: Alignment.bottomRight,
                                              //   child: Text('$formattedTime',))
                                            ],
                                          ),
                                              ),
                                    ],
                                  );
                                }); //yaha ham snapshot.data ko QuerySnapshot convert karenge jisase ham document me se data fecth kar sake
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  "An Error occured! Please cheak your internet connection"),
                            );
                          } else {
                            return const Center(
                              child: Text("Say hi to new friend"),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }), //streamBuilder ka use karake ham firebse me storage data ko app ke screen per show karate h
                )),
                Container(
                  // color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5),
                  child: Row(children: [
                    Flexible(
                        child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Send message...",
                        filled: true,
                        contentPadding:const EdgeInsets.only(left: 20.0),
                        fillColor:  Colors.yellow[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none
                        )
                        ),
                    )),
                    const SizedBox(width: 5,),
                    CircleAvatar(
                      backgroundColor:  Colors.yellow[400],
                      radius: 25,
                      child: IconButton(
                          onPressed: () {
                            sendMessage();
                          },
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.secondary,
                          )),
                    )
                  ]),
                )
              ],
            )),
      ),
    );
  }
}
