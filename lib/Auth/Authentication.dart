import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/profile/UserProfile.dart';


class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  String phoneNumber='';
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void onPhoneNumberChange(String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
       phoneNumber = internationalizedPhoneNumber;
    });
  }

    void  userSharedPreference()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('user', _firebaseAuth.currentUser.uid);
    var number = _firebaseAuth.currentUser.phoneNumber.trim();
    if(number.length == 13){
      var pNo = number.substring(3);
      pref.setString('phone_number', pNo.replaceAll(' ',''));
    }
    pref.setString('login', 'true');
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text('Enter your phone number',
              style: TextStyle(
                color: Color(0xFF00BFA5),
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
            actions: [
              Icon(Icons.more_vert),
            ],
          ), 
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              SizedBox(height:30.0),
              Text('WhatsApp will send an SMS message to verify your phone number.'),
              InternationalPhoneInput(
                  onPhoneNumberChange: onPhoneNumberChange, 
                  initialPhoneNumber: phoneNumber,
                  initialSelection: '+91',
              ),
              RaisedButton(
                elevation: 6.0,
                color: Colors.lightGreen,
                onPressed: (){
                    
                  if(phoneNumber != ""){
                    _firebaseAuth.verifyPhoneNumber(
                                        phoneNumber: phoneNumber,   
                                        timeout: Duration(seconds:30),
                                        verificationCompleted: (PhoneAuthCredential credential)async{
                                              await _firebaseAuth.signInWithCredential(credential);
                                              userSharedPreference();
                                              Navigator.push(context , MaterialPageRoute(builder: (context)=>UserProfile()));
                                          },  
                                       verificationFailed: (FirebaseAuthException exception){
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context){
                                                            return AlertDialog(
                                                                    title: Text('Verification Failed'),
                                                                    content: Text(exception.toString()),
                                                                    actions: [
                                                                        FlatButton(
                                                                          onPressed: (){
                                                                             Navigator.pop(context);
                                                                            }, 
                                                                          child: Text('OK'),
                                                                        ),
                                                                    ],
                                                              );
                                                      },                    
                                                 );
                                            },

                                        codeSent: (String verificationId, int resendToken){
                                              String sms='';
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext context){
                                                          return AlertDialog(
                                                              title: Text('Enter Your verification Code'),
                                                              content: Column(
                                                                    children: [
                                                                        TextField(
                                                                            onChanged: (value){
                                                                                sms = value;
                                                                              },
                                                                          ),
                                                                       ],
                                                                 ),
                                                              actions: [
                                                                  FlatButton(
                                                                      onPressed: (){
                                                                        Navigator.pop(context);                                                                                                                                                      
                                                                        }, 
                                                                    child: Text('CANCEL'),
                                                                   ),
                                                                  FlatButton(
                                                                      onPressed: ()async{
                                                                          if( sms != ""){
                                                                            PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: sms);
                                                                            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
                                                                            userSharedPreference();
                                                                            Navigator.push(context , MaterialPageRoute(builder: (context)=>UserProfile()));
                                                                          }                                                                                                                                                                       
                                                                        }, 
                                                                    child: Text('SUBMIT'),
                                                                   ),

                                                                ],
                                                        );
                                                  }
                                                );
                                            }, 
                                        codeAutoRetrievalTimeout: (String verificationId){
                                             }
                    );//end of verify phone
                  }//end id
               },//end of onPressed
                child: Text('NEXT',
                            style: TextStyle(
                            color: Colors.white,
                            ),
                       ),
                ), 
            ]
          ),  
           
       ),
      ),
    );
  }
}