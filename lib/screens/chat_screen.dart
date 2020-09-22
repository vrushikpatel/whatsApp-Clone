import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/contact.dart';
import 'package:whatsapp/screens/Actions_chat/Select_Contact.dart';

class Chat extends StatefulWidget {

   const Chat({
    Key key,
  }) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  List contList ;
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
      body:path == null && contList == null ? SizedBox() :   StreamBuilder<QuerySnapshot>(
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
            onPressed: (){
              contList = Provider.of<ContactList>(context).contactList;
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectContact(contacts: contList) ));
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