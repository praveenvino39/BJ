// ignore_for_file: depend_on_referenced_packages, empty_catches

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet_cryptomask/core/model/contact_model.dart';

ContactProvider getContactProvider(BuildContext context) =>
    context.read<ContactProvider>();

ContactProvider getContactProviderLive(BuildContext context) =>
    Provider.of<ContactProvider>(context);

class ContactProvider extends ChangeNotifier {
  final Box box;
  List<Contact> contacts = [];
  List<Contact> filtered = [];
  ContactProvider({required this.box});

  loadContacts() {
    var contacts =
        box.get("contacts", defaultValue: <Contact>[]) as List<dynamic>;
    this.contacts = contacts.cast<Contact>();
    filtered = this.contacts;
    notifyListeners();
    return contacts;
  }

  updateFiltered(List<Contact> filtered) {
    this.filtered = filtered;
    filtered.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  getContactName({required String address}) {
    try {
      Contact foundContact =
          contacts.firstWhere((element) => element.address == address);
      return foundContact.name;
    } catch (e) {
      return "Unknown address";
    }
  }

  addContacts(
      {required String name,
      required String address,
      required String network,
      required Function alreadyExist}) {
    var contacts = box.get("contacts", defaultValue: <Contact>[]);
    try {
      Contact _ = contacts.firstWhere((element) {
        return element.address == address && element.networkId == network;
      });
      alreadyExist();
    } catch (e) {
      Uuid uuid = const Uuid();
      contacts.add(Contact(
          name: name, address: address, networkId: network, id: uuid.v1()));
      box.put("contacts", contacts);
      this.contacts = contacts.cast<Contact>();
      filtered = this.contacts;
      notifyListeners();
    }
  }

  deleteContacts({required String address, required Function alreadyExist}) {
    var contacts = box.get("contacts", defaultValue: <Contact>[]);
    try {
      List<Contact> updatedContacts = (contacts as List<dynamic>)
          .cast<Contact>()
          .where((e) => e.address != address)
          .toList();
      box.put("contacts", updatedContacts);
      this.contacts = updatedContacts.cast<Contact>();
      filtered = this.contacts;
      notifyListeners();
    } catch (e) {}
  }

  updateContact(
      {required String id, required String address, required String name}) {
    var contacts = box.get("contacts", defaultValue: <Contact>[]);
    try {
      List<Contact> updatedContacts =
          (contacts as List<dynamic>).cast<Contact>().map((e) {
        if (e.id == id) {
          return Contact(
              id: id, address: address, name: name, networkId: e.networkId);
        }
        return e;
      }).toList();
      box.put("contacts", updatedContacts);
      this.contacts = updatedContacts.cast<Contact>();
      filtered = this.contacts;
      notifyListeners();
    } catch (e) {}
  }
}
