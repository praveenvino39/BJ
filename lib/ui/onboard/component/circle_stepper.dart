import 'package:flutter/material.dart';

import '../../../constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class CircleStepper extends StatefulWidget {
  int currentIndex;

  CircleStepper({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<CircleStepper> createState() => _CircleStepperState();
}

class _CircleStepperState extends State<CircleStepper> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 2,
                color: kPrimaryColor,
              ),
            ),
          ),
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: widget.currentIndex > 0
                          ? kPrimaryColor
                          : Colors.white,
                      border: Border.all(
                          color: widget.currentIndex >= 0
                              ? kPrimaryColor
                              : Colors.grey,
                          width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text(
                      "1",
                      style: TextStyle(
                          fontSize: 10,
                          color: widget.currentIndex > 0
                              ? Colors.white
                              : Colors.black),
                    )),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.createPassword,
                    style: TextStyle(
                        fontSize: 9,
                        color: widget.currentIndex >= 0
                            ? kPrimaryColor
                            : Colors.black),
                  )
                ],
              ),
              Expanded(
                child: Container(),
              ),
              Column(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: widget.currentIndex > 1
                          ? kPrimaryColor
                          : Colors.white,
                      border: Border.all(
                          color: widget.currentIndex >= 1
                              ? kPrimaryColor
                              : Colors.grey,
                          width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text(
                      "2",
                      style: TextStyle(
                          fontSize: 10,
                          color: widget.currentIndex > 1
                              ? Colors.white
                              : Colors.black),
                    )),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                   AppLocalizations.of(context)!.secureWallet,
                    style: TextStyle(
                        fontSize: 9,
                        color: widget.currentIndex >= 1
                            ? kPrimaryColor
                            : Colors.black),
                  )
                ],
              ),
              Expanded(
                child: Container(),
              ),
              Column(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: widget.currentIndex >= 2
                              ? kPrimaryColor
                              : Colors.grey,
                          width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text(
                      "3",
                      style: TextStyle(
                          fontSize: 10,
                          color: widget.currentIndex > 2
                              ? Colors.white
                              : Colors.black),
                    )),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context)!.confirmSeed,
                    style: TextStyle(
                        fontSize: 9,
                        color: widget.currentIndex >= 2
                            ? kPrimaryColor
                            : Colors.black),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
