import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final Contact contact;
  const ChatPage({
    Key key,
    this.contact,
  }) : super(key: key);
 
  @override
  _ChatPageState createState() => _ChatPageState();
  }

class _ChatPageState extends State<ChatPage> {

  DateTime now = DateTime.now();
  List<MessageBubbles> messageBubbles =[];
  User user;
  String newMsg;
  final messageTextController = TextEditingController();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  var senderNo;
  var receiverNo;
  bool keyBoardshow = false;
  bool emojiShow= false;
  File img;
  var url;
  StorageReference _storageReference;
  
  Future <void> pickImage(ImageSource source)async{
    final selectedImg = await ImagePicker().getImage(source: source);
    String pathOfImg = selectedImg.path;
    img = File(pathOfImg);
    _storageReference = FirebaseStorage.instance.ref().child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask _storageUploadtask = _storageReference.putFile(img);
    url = await (await _storageUploadtask.onComplete).ref.getDownloadURL();
   
  }

  void assignSenderreceiver()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    senderNo = pref.getString('phone_number');
    var receiver = widget.contact.phones.elementAt(0).value.replaceAll(' ', '');
    if(receiver.length == 13){
      receiverNo = receiver.substring(3);
    }
    else{
      receiverNo = receiver;
    }    
    setState(() {
     path = _firebaseFirestore.collection('messages').doc(senderNo).collection(receiverNo).orderBy("time",descending : true).snapshots(); 
    });

  }
  Stream path;
  @override
  void initState() {
    assignSenderreceiver();
    super.initState();
  }
  @override
  void dispose() {
    path = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      appBar: AppBar(
        title:Row(
          children:[
             widget.contact.avatar != null && widget.contact.avatar.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(widget.contact.avatar),
                        )
                      : CircleAvatar(
                          child: Text(widget.contact.initials()),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
            
            SizedBox(width:5.0),
            Flexible(
              child: Text(widget.contact.displayName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )),
            ),
          ]
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: (){
            },
          ),
          SizedBox(width:15.0),
          Icon(Icons.call),
          SizedBox(width:15.0),
          Icon(Icons.more_vert),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children :[
            Expanded(
              child: path == null ? SizedBox() : StreamBuilder<QuerySnapshot>(
              stream: path,
              builder: (BuildContext context,snapshot) {
                          if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  backgroundColor : Colors.blueAccent,
                                ),
                              );
                          }
                      final messages = snapshot.data.docs; 
                      
                    return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index){
                      return MessageBubbles(msg: messages[index].data()['message'],isME: messages[index].data()['sender']==senderNo,time: messages[index].data()['time'],url: messages[index].data()['url'],type: messages[index].data()['msgType'],);
                    },
                    );
                       },
            ),
          ),// for chat part
          Row(// for typing  part
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 2.0),
              Container(
                width: (MediaQuery.of(context).size.width)*0.8,
                height: 40.0,
                decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(25.0) ,
                border: Border.all(color:Colors.black87),
                ),
                child: Row(
                    children:[
                      Expanded(
                        flex: 1,
                        child : IconButton(
                          icon: Icon(Icons.mood),
                          onPressed: (){       
                          },
                        ), 
                      ),
                      SizedBox(width:5.0),
                      Expanded(
                          flex: 5,
                          child: Container(
                          width: ((MediaQuery.of(context).size.width)*0.5)+11.0,
                          child: TextField(   
                          controller: messageTextController,
                          decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:'Type a message',
                          ),
                          onChanged: (value){
                            newMsg = value;
                          },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.attach_file),
                          onPressed: (){
                            print('attch file pressed');
                          },
                        ), 
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon :  Icon(Icons.local_see),
                          onPressed: ()async{
                            await pickImage(ImageSource.camera);
                            String formattedDate = DateFormat(' d/M/y -- kk:mm:ss ').format(now);

                            _firebaseFirestore
                            .collection('messages')
                            .doc(senderNo)
                            .collection(receiverNo)
                            .add({
                              "message" : '',
                              "sender" : senderNo,
                              "receiver" : receiverNo,
                              "time" : formattedDate, 
                              "msgType" : 'image',
                              "url" : url ,
                            });

                             _firebaseFirestore
                            .collection('messages')
                            .doc(receiverNo)
                            .collection(senderNo)
                            .add({
                              "message" : '',
                              "sender" : senderNo,
                              "receiver" : receiverNo,
                              "time" : formattedDate, 
                              "msgType" : 'image',
                              "url" : url ,
                              }).then((value) => print('image upload successfull')).catchError((error)=>print('error is :--- $error'));

                     _firebaseFirestore
                    .collection('messages')
                    .doc('Recent_Chat')
                    .collection(senderNo)
                    .doc(receiverNo)
                    .set({
                      "lastMsg" : 'photo',
                      "sender" : senderNo,
                      "receiver" : receiverNo,
                      "time" : formattedDate, 
                    });

                    _firebaseFirestore
                    .collection('messages')
                    .doc('Recent_Chat')
                    .collection(receiverNo)
                    .doc(senderNo)
                    .set({
                      "lastMsg" : 'photo',
                      "sender" : senderNo,
                      "receiver" : receiverNo,
                      "time" : formattedDate, 
                    });
                          },
                        ), 
                      ),
                    ]
                  ),    
              ),
              MaterialButton(
                minWidth: (MediaQuery.of(context).size.width)*0.1,
                height: 40.0,
                color: Theme.of(context).primaryColor,
                onPressed: ()async{
                  if(newMsg != null){
                    messageTextController.clear();
                    String formattedDate = DateFormat(' d/M/y -- kk:mm:ss ').format(now);   
                    _firebaseFirestore
                    .collection('messages')
                    .doc(senderNo)
                    .collection(receiverNo)
                    .add({
                      "message" : newMsg,
                      "sender" : senderNo,
                      "receiver" : receiverNo,
                      "time" : formattedDate, 
                      "msgType" : 'text',
                      "url" : '',
                    });

                    _firebaseFirestore
                    .collection('messages')
                    .doc(receiverNo)
                    .collection(senderNo)
                    .add({
                      "message" : newMsg,
                      "sender" : senderNo,
                      "receiver" : receiverNo,
                      "time" : formattedDate, 
                      "msgType" : 'text',
                      "url" : '',
                    }).then((value) => print('data upload successfull')).catchError((error)=>print('error is :--- $error'));

                  //add to recent 

                  _firebaseFirestore
                    .collection('messages')
                    .doc('Recent_Chat')
                    .collection(senderNo)
                    .doc(receiverNo)
                    .set({
                      "lastMsg" : newMsg,
                      "sender" : senderNo,
                      "receiver" : receiverNo,
                      "time" : formattedDate, 
                    });

                    _firebaseFirestore
                    .collection('messages')
                    .doc('Recent_Chat')
                    .collection(receiverNo)
                    .doc(senderNo)
                    .set({
                      "lastMsg" : newMsg,
                      "sender" : senderNo,
                      "receiver" : receiverNo,
                      "time" : formattedDate, 
                    });

                  }
                },
                child:  Icon(Icons.send,
                color: Colors.white70),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ],
          ),
        ]
      ),      
    );
  }
}

//message bubble
class MessageBubbles extends StatelessWidget {
  final String msg;
  final String url;
  final String time;
  final bool isME;
  final String type;
  MessageBubbles({this.msg,this.isME,this.time,this.url,this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0,horizontal:10.0),
      child: Column(
        crossAxisAlignment : isME ?  CrossAxisAlignment.end : CrossAxisAlignment.start ,
        children: [
          Container(
            decoration: type == "text" ? BoxDecoration(
              color:isME ? Colors.lightGreen : Colors.white ,
               borderRadius: isME ? BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      ) :
                      BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      )

            ) : BoxDecoration(),
            child: ListTile(
            title:  Row(
                children: [
                 type == "text" ?
                  Text(msg,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                         ),
                )
                : SizedBox(
                  height :200.0,
                  width : 150.0,
                  child : Image.network(url),
                ) ,
                  Text(time,
                      style: TextStyle(
                            fontSize: 10.0,
                      ),
                      ),
                ],
              ),
                ),
            ),
        ],
      ),
    );
  }
}







