import 'dart:async';

import 'package:chat_app/screens/auth/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(
          seconds: 3,
        ), () {
          Navigator.push(context,MaterialPageRoute(builder:(context){
           return const LoginPage();
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.yellow[300],
      body: Column(
        children: [
          const SizedBox(height: 250,),
          Text("Chat Sphere",style:GoogleFonts.acme(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            color:Theme.of(context).colorScheme.secondary
          ),),
          Center(child:Lottie.asset('assets/indicator.json')),
        ],
      ),
    );
  }
}