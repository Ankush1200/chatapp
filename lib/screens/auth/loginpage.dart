import 'package:chat_app/model/UIhelper.dart';
import 'package:chat_app/screens/home/homepage.dart';
import 'package:chat_app/screens/auth/signuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/usermodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the Field");
    } else {
      loginUp(email, password);
    }
  }

  void loginUp(String email, String password) async {
    //FirebaseAuth hame Ak UserCredential class provide katata h
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Loading...");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      //for closing loading dialog
      Navigator.pop(context);
      //for showing alert
      UIHelper.showAlertDialog(
          context, "An error ocuured", ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      //here DocumentSnapshot ak class h FirebaseFirestore ka jisaka use karake ham ak object create karate here jisaka name userData h
      //here ham log firebase se data fetch kar rahe h
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      UserModel
          userModel = //as keyword ka use karake ham data() ko map convert karate h jise userModel me store karate h
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      Get.snackbar("Login user ", "Login Up is Successfully!",
          snackPosition: SnackPosition.BOTTOM);

      print("Login is Successfully");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));
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
              const SizedBox(height: 80,),
                Text(
                  "Chat Sphere",
                  style: GoogleFonts.acme(
                    fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary
                  )
                ),
                Text(
                  "Your Own Messaging App",
                  style: GoogleFonts.acme(
                    fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary
                  )
                ),
                SizedBox(
                  height: 60,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                const SizedBox(
                  height: 60,
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
                        child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 15),),
                      ),
                    ),
                  ],
                ),
                            ],
                          ),
              ))),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
            borderRadius: BorderRadius.circular(30),
              child: Text("Sign up"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SignUpPage();
                }));
              })
        ]),
      ),
    );
  }
}
