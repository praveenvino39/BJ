import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet_cryptomask/core/providers/contact_provider/contact_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/screens/contacts-screen/widgets/add_contact.dart';
import 'package:wallet_cryptomask/ui/screens/contacts-screen/widgets/contact_tile.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text_field.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';

import '../../../core/model/contact_model.dart';

class AllContactScreen extends StatefulWidget {
  static const route = "all_contact_screen";
  const AllContactScreen({super.key});

  @override
  State<AllContactScreen> createState() => _AllContactScreenState();
}

class _AllContactScreenState extends State<AllContactScreen> {
  final TextEditingController _search = TextEditingController();
  String sort = "A-Z";

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  getContacts() {
    final contactProvider = getContactProvider(context);
    List<Contact> filteredContacts = [];

    _search.addListener(() {
      filteredContacts = contactProvider.contacts
          .where((element) =>
              element.name.toLowerCase().startsWith(_search.text.toLowerCase()))
          .toList();
      contactProvider.updateFiltered(filteredContacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const WalletText(
            localizeKey: "contacts",
            size: 16,
            fontWeight: FontWeight.w700,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Get.bottomSheet(
                    AddContact(mode: "CREATE"),
                  );
                },
                icon: const Icon(
                  Icons.add,
                ))
          ]),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 80,
          child: Column(
            children: [
              addHeight(SpacingSize.m),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: WalletTextField(
                  textEditingController: _search,
                  labelLocalizeKey: 'search',
                  textFieldType: TextFieldType.input,
                ),
              ),
              getContactProviderLive(context).filtered.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        if (sort == "A-Z") {
                          getContactProvider(context)
                              .filtered
                              .sort(((a, b) => b.name.compareTo(a.name)));
                          sort = "Z-A";
                        } else {
                          getContactProvider(context)
                              .filtered
                              .sort(((a, b) => a.name.compareTo(b.name)));
                          sort = "A-Z";
                        }
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Text("${getText(context, key: 'sortBy')} $sort"),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
              Expanded(
                child: getContactProviderLive(context).filtered.isNotEmpty
                    ? ListView.builder(
                        itemCount:
                            getContactProviderLive(context).filtered.length,
                        itemBuilder: (context, index) {
                          final contact =
                              getContactProviderLive(context).filtered[index];
                          return ContactTile(
                              key: Key(contact.address),
                              name: contact.name,
                              address: contact.address,
                              network: "",
                              id: contact.id,
                              mode: "VIEW",
                              onChoose: (address) {});
                        })
                    : const Center(
                        child: WalletText(
                          localizeKey: 'noContactAndNew',
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
