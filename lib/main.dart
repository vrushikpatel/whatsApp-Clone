import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whatsapp/Auth/Authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/screens/welcome_screen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences pref = await SharedPreferences.getInstance();
  String log = pref.getString('login');
  runApp(
     MaterialApp(
       home: log == 'true' ? MyApp() : Authentication(),
     )
    );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WelcomePage();
  }
}
