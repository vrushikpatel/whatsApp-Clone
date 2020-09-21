import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/screens/Actions_chat/Select_Contact.dart';

class Chat extends StatefulWidget {

   const Chat({
    Key key,
  }) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  List contact ;
  var senderNo;
  void getReceiver()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    senderNo = pref.getString('phone_number');
    setState(() {
          path = FirebaseFirestore.instance.collection('messages').doc('Recent_Chat').collection(senderNo).orderBy('time',descending: true).snapshots();
    });
  }

  @override
  void initState() {
    getReceiver();
    super.initState();
  }
  Stream path;
  @override
  void dispose() {
    path = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:path == null ? SizedBox() :   StreamBuilder<QuerySnapshot>(
        stream: path,
        builder: (BuildContext context, snapshot){
                       if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor : Colors.blueAccent,
                                ),
                              );
                        }
                    final  messages = snapshot.data.docs;
                    
          return ListView.builder(
            itemCount: messages.length,
           itemBuilder: (context , index){
             return Recent(senderNo: messages[index].data()['receiver'], msg:  messages[index].data()['lastMsg']);
           },
           );
        } 
        ),

      floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: ()async{
              final PermissionStatus permissionStatus = await _getPermission();
              if (permissionStatus == PermissionStatus.granted) {
                  Iterable<Contact> contacts = await ContactsService.getContacts();
                  if(contacts == null){
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return CircularProgressIndicator(backgroundColor : Colors.blueAccent);
                      },
                      );
                  }
                  contact = contacts.toList();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectContact(contacts: contact)));
                  
              }
              else {
                  //If permissions have been denied show standard cupertino alert dialog
                 showDialog(
                 context: context,
                 builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text('Permissions error'),
                    content: Text('Please enable contacts access '
                        'permission in system settings'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
                }
             },
            child: 
            Icon(
            Icons.chat,
            color: Colors.white,
            ),
            ),
    );
  }
}


  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }


class Recent extends StatelessWidget {
  final String senderNo,msg;
  Recent({this.senderNo,this.msg});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
      radius : 25.0,
      backgroundColor: Colors.lightGreenAccent,
      ),
      title: Text(senderNo),
      subtitle: Text(msg),
    );
  }
}