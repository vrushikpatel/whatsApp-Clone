import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:whatsapp/screens/Actions_chat/Chat_Page.dart';

class SelectContact extends StatefulWidget {

  final List<Contact> contacts;
  const SelectContact({
    Key key,
    @required this.contacts,
  }) : super(key: key);
  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Row(
         children:[
           Text('Selectcontact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
           ),
         ]
       ),
       actions: [
            Icon(Icons.search),
            SizedBox(width: 5.0),
            Icon(Icons.more_vert),
          ],
      ),
      body: widget.contacts != null
          
          ? ListView.builder(
              itemCount: widget.contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = widget.contacts?.elementAt(index);
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar),
                        )
                      : CircleAvatar(
                          child: Text(contact.initials()),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                  title: Text(contact.displayName ?? ''),
                  onTap:(){
                         Navigator.push(context , MaterialPageRoute(builder: (context)=>ChatPage(contact: contact)));
                    },
                );
              },
            )
          : Center(child: const CircularProgressIndicator()),
      
    );
  }
}
