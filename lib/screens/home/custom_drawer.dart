import 'package:chat_app/screens/auth/loginpage.dart';
import 'package:chat_app/screens/payment/pay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:Colors.yellow[400],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), bottomRight: Radius.circular(30),),
      ), 
      child:Wrap(
        runSpacing:10,
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),),
          ListTile(
            titleAlignment:ListTileTitleAlignment.center, 
            title: Text('Chat Sphare'),
            subtitle: Text('1.14.0'),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Text('CS',style:GoogleFonts.acme(
                  fontSize:15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary
                ),),
            ),
          ),
          // Divider(
          //   indent:10,
          //   endIndent:10,
          //   thickness: 1.5,
          //   color: Colors.grey,
          // ),
          ListTile(
            titleAlignment:ListTileTitleAlignment.center, 
            title:const Text('Payments'),
            leading:const Icon(Icons.payment),
            trailing: const Icon(Icons.arrow_forward), 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const PaymentWithStripe()));
            },           
          ), 

          ListTile(
            titleAlignment:ListTileTitleAlignment.center, 
            title: Text('Logout'),
            leading: Icon(Icons.logout),
            trailing:Icon(Icons.arrow_forward), 
            onTap: () async {
                await FirebaseAuth.instance.signOut();
                //Navigator.pop() se current page band ho jata h but Navigator.popUntil() se tab tak page pop hoga jab tak  jo ham condition diye ho vo true na ho jaye
                Navigator.popUntil(context, (route) => route.isFirst);
                //Navigator.pushReplacement() jo current page hoti h use replace kar deta h
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }));
              }          
          ), 
        ],
      ),
    );
  }
}
