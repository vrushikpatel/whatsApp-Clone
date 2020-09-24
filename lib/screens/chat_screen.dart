import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/models/contact.dart';
import 'package:whatsapp/screens/Actions_chat/Select_Contact.dart';
import 'package:contacts_service/contacts_service.dart';

class Chat extends StatefulWidget {
   const Chat({
    Key key,
  }) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ContactList ctn = ContactList();
  List<Contact> contList ;
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
    contList = Provider.of<ContactList>(context).contactList;
    return Scaffold(
      body:path == null || contList == null  ? Center(
                                child : CircularProgressIndicator(
                                                      backgroundColor : Colors.blueAccent,
                                          )
                                ) : StreamBuilder<QuerySnapshot>(
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
            itemCount:  messages.length,
           itemBuilder: (context , index){
            //  Contact ctn =returnCtnObj(messages[index].data()['receiver'],contList);
            // print(contList.length);
            // Contact ctn ;
            //  for(int i=0; i<contList.length;i++){
            //    print(i);
              // print(contList[i].phones.elementAt(0).value.toString());
              //  print(messages[index].data()['receiver']);
              // if(messages[index].data()['receiver'] == (contList[i].phones.elementAt(0).value).toString()){
              //     print('===================================================================================');
                  // print(contList[i].displayName);
                  // ctn = contList[i];
                  // break;}
             //}
             return Recent(senderNo: messages[index].data()['receiver'], msg:  messages[index].data()['lastMsg']);
           },
          );
        } 
        ),

      floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: (){              
             Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectContact(contacts: contList)));            
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



// Contact returnCtnObj(String number,List<Contact>contactList){
//     for(int i=0;i<contactList.length;++i){
//       if(number == contactList[i].phones.elementAt(0).value){
//          print('===================================================================================');
//         print(contactList[i].displayName);
//         return contactList[i]; 
//       }
//     }
//   }

class Recent extends StatelessWidget {
  final String senderNo,msg;
  final Contact ctn;
  Recent({this.senderNo,this.msg,this.ctn});  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.lightGreenAccent,
      ),             
      title: Text(senderNo),
      subtitle: Text(msg),
      onTap: (){       
      },
    );
  }
}

