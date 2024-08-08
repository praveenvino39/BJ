// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/providers/contact_provider/contact_provider.dart';
import 'package:wallet_cryptomask/core/providers/wallet_provider/wallet_provider.dart';
import 'package:wallet_cryptomask/l10n/transalation.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import '../../../shared/wallet_text_field.dart';

class AddContact extends StatefulWidget {
  String mode = "CREATE";
  String? address;
  String? name;
  String? id;

  AddContact({
    Key? key,
    this.id,
    this.address,
    this.name,
    this.mode = "CREATE",
  }) : super(key: key);

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final TextEditingController name = TextEditingController(text: "");

  final TextEditingController address = TextEditingController(text: "");

  final GlobalKey<FormState> _formkey = GlobalKey();

  @override
  void initState() {
    if (widget.address != null) {
      address.text = widget.address!;
    }
    if (widget.name != null) {
      name.text = widget.name!;
    }
    if (widget.id != null) {
      name.text = widget.name!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        decoration: const BoxDecoration(color: Colors.white),
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WalletText(
                localizeKey:
                    widget.mode == "CREATE" ? 'addContact' : 'updateContact',
                size: 22,
              ),
              addHeight(SpacingSize.m),
              WalletTextField(
                labelLocalizeKey: "name",
                textFieldType: TextFieldType.input,
                validator: ((value) {
                  if (value!.isEmpty) {
                    return getText(context, key: 'notEmpty');
                  }
                  return null;
                }),
                textEditingController: name,
              ),
              addHeight(SpacingSize.m),
              WalletTextField(
                validator: ((value) {
                  value = value!.trim();
                  if (value.isEmpty) {
                    return "publicAddressNotEmpty";
                  }
                  if (value.length != 42) {
                    return "invalidAddress";
                  }
                  return null;
                }),
                textFieldType: TextFieldType.input,
                textEditingController: address,
                labelLocalizeKey: "publicAddress",
              ),
              addHeight(SpacingSize.s),
              WalletButton(
                localizeKey: widget.mode == "CREATE" ? "add" : "update",
                onPressed: () {
                  bool isValid = _formkey.currentState?.validate() ?? false;
                  if (isValid && widget.mode == "CREATE") {
                    getContactProvider(context).addContacts(
                        name: name.text,
                        address: address.text,
                        network: getWalletProvider(context)
                            .activeNetwork
                            .networkName,
                        alreadyExist: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: WalletText(
                              localizeKey: 'contactExist',
                            ),
                            backgroundColor: kPrimaryColor,
                          ));
                        });
                  }
                  if (isValid && widget.mode == "UPDATE") {
                    if (isValid) {
                      getContactProvider(context).updateContact(
                          id: widget.id ?? "",
                          name: name.text,
                          address: address.text);
                    }
                  }
                  Get.back();
                },
                type: WalletButtonType.filled,
              )
            ],
          ),
        ));
  }
}
