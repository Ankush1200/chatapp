import 'package:chat_app/model/UIhelper.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:chat_app/screens/chatroom/completeprofilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();
    if (email == "" || password == "" || cpassword == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the Field");
    } else if (password != cpassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The Password you entered do not match");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    //FirebaseAuth hame Ak UserCredential class provide katata h
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Created New Account....");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      //for closing loading dialog
      Navigator.pop(context);
      //for showing alert
      UIHelper.showAlertDialog(
          context, "An error ocuured", ex.message.toString());
    }
    if (credential != null && credential.user != null) {
      String uid = credential.user!.uid;
      UserModel createUser =
          UserModel(uid: uid, fullName: "", email: email, profilePic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(createUser.toMap())
          .then((value) {
        Get.snackbar("New User Created ", "Sign Up is Successfully!",
            snackPosition: SnackPosition.BOTTOM);
        print("New User Created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              userModel: createUser,
              firebseUser: credential!
                  .user!); //! ye sign chack karata h ki jo variable ho skata h vo null to nahi h
        }));
      });
    } else {
      Get.snackbar("Error", "Null check operator used on a null value",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height:80,),
                Text("Chat Sphere",
                  style:GoogleFonts.acme(
                    fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: emailController,
                  decoration:const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: cpasswordController,
                  obscureText: true,
                  decoration:const InputDecoration(labelText: "Confirm Password"),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          checkValue();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          elevation: 0
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 12),
                          child: Text("Sign Up",style: TextStyle(color: Colors.white,fontSize: 15),),
                        ),
                      ),
                    ],
                  ),
                ],),
              ))),
      bottomNavigationBar: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          "Allready have an account?",
          style: TextStyle(fontSize: 16),
        ),
        CupertinoButton(
            child: const Text("Sign In"),
            onPressed: () {
              Navigator.pop(
                  context); //signUpPage ko pop(remove) karane ke liye use karate h
            })
      ]),
    );
  }
}
