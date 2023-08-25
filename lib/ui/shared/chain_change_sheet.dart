// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wallet/core/bloc/wallet-bloc/cubit/wallet_cubit.dart';
import 'package:wallet/core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChainChangeSheet extends StatelessWidget {
  const ChainChangeSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: AlertDialog(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                "Networks",
              ),
            ),
            InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.close))
          ],
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black45.withAlpha(20),
          child: SizedBox(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: Core.networks.length,
                  itemBuilder: (context, index) => ListTile(
                        tileColor: Colors.transparent,
                        onTap: () async {
                          await context
                              .read<WalletCubit>()
                              .changeNetwork(Core.networks[index]);
                          Navigator.of(context).pop();
                        },
                        title: Row(
                          children: [
                            NetworkDot(
                              color: Core.networks[index].dotColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(Core.networks[index].networkName
                                .replaceAll("_", " ")),
                          ],
                        ),
                      ))),
        ),
      ),
    );
  }
}

class NetworkDot extends StatelessWidget {
  final Color color;
  final double radius;
  const NetworkDot({Key? key, required this.color, this.radius = 7.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(radius)),
    );
  }
}
