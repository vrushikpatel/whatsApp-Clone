import 'package:flutter/material.dart';
import 'package:whatsapp/models/contact.dart';
import 'package:whatsapp/screens/camera_screen.dart';
import 'chat_screen.dart';
import 'calls_screen.dart';
import 'status_screen.dart';
import 'package:provider/provider.dart';


class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {

  TabController tabcontroller;
  
  @override
  void initState() {
    tabcontroller=TabController(length: 4, vsync: this,initialIndex: 1);
    Future.delayed(Duration.zero).then((value) {
      Provider.of<ContactList>(context,listen: false).getContact();
    });
   
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xff075E54),
        accentColor: Color(0xff25D366),
      ),
      home: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('WhatsApp',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          ),
          bottom: TabBar(
            controller: tabcontroller,
            tabs: [
            Tab(icon: Icon(Icons.camera_alt)),
            Tab(icon: Text('CHAT')),
            Tab(icon: Text('STATUS')),
            Tab(icon:  Text('CALLS')),
          ]),
          actions: [
            Icon(Icons.search),
            SizedBox(width: 5.0),
            Icon(Icons.more_vert),
          ],
        ),
        body:TabBarView(
          controller: tabcontroller,
            children:[
              Camera(),
              Chat(),
              StatusScreen(),
              CallScreen(),
            ]
          ),
        ),
     ),
    );
  }
}