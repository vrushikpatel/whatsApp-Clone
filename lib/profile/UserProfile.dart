import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';


  String username;
  class UserProfile extends StatelessWidget {
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
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
    print(url);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: SafeArea(
        child:Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text('Profile info',
                    style: TextStyle(
                      color: Color(0xFF00BFA5),
                     ),
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height:50.0),
              Text('Please provide your name and optional profie photo'),
              SizedBox(height:50.0),
              GestureDetector(
                  child: CircleAvatar(
                    child: Icon(Icons.add_a_photo),
                  radius: 50.0,
                ),
                onTap: (){
                  showModalBottomSheet(context: context,
                   builder: (BuildContext context){
                     return Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         IconButton(
                           icon: Icon(Icons.camera_alt,
                                      size: 40.0,
                                      ), 
                           onPressed: () async {
                             await pickImage(ImageSource.camera);
                           }
                           ),
                           IconButton(
                           icon: Icon(Icons.photo,
                                      size: 40.0,
                                      ), 
                           onPressed: () async {
                             await pickImage(ImageSource.gallery);
                           }
                           ),
                       ],
                     );
                  });
                },
              ),
              TextField(  
                decoration: InputDecoration(
                hintText: 'Type your name here',
                enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color : Colors.green)
                ),
                focusedBorder: UnderlineInputBorder(
          borderSide:BorderSide(color:Colors.green)
                )
                ),
                maxLength: 15,
                textCapitalization: TextCapitalization.words,
                onChanged: (value){
                     username = value;
                 },
              ),
              SizedBox(height:100.0),
              RaisedButton(
                onPressed: ()async{
                 if(username != ""){
                 SharedPreferences pref =await SharedPreferences.getInstance();
                 var userid = pref.getString('user');
                 var phoneNumber = pref.getString('phone_number');
                 collectionReference
                                    .doc(userid)
                                    .set({
                                      "prifile_name" : username,
                                      "phone_number" : phoneNumber ,
                                      "photo_url" : url,
                                    });
            Navigator.push(context, MaterialPageRoute(builder: (context)=>WelcomePage()));
          }
                },
                elevation: 6.0,
                color: Colors.lightGreen,
                child: Text('NEXT',
                    style: TextStyle(
                    color: Colors.white,
                    ),
               ),
              ),
            ],
              )
        ),
     ),
    );
  }
}