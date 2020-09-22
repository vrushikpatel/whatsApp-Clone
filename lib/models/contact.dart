import 'package:flutter/cupertino.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactList extends ChangeNotifier{

  List <Contact> contactList = [];


   Future<void> getContact()async{
    print('getcontect called');
  final PermissionStatus permissionStatus = await _getPermission();
  print('inisde permission');
              if (permissionStatus == PermissionStatus.granted) {
                  Iterable<Contact> contacts = await ContactsService.getContacts();
                    contactList = contacts.toList();
                    print(contactList);
                    notifyListeners();
              }
    }

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
  
}

