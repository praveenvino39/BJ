import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jazzicon/jazzicon.dart';

import '../../../core/bloc/wallet-bloc/cubit/wallet_cubit.dart';

class AvatarWidget extends StatelessWidget {
  final double radius;
  final String address;
  final String? iconType;
  final String? imageUrl;
  const AvatarWidget(
      {Key? key,
      required this.radius,
      required this.address,
      this.iconType,
      this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: imageUrl != null
                ? imageUrl!.contains("asset")
                    ? null
                    : Border.all(color: Colors.black, width: 2)
                : Border.all(color: Colors.black, width: 2),
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: imageUrl != null
              ? imageUrl!.contains("http")
                  ? CachedNetworkImage(
                      imageUrl: imageUrl ?? "",
                      height: radius,
                      width: radius,
                      errorWidget: (context, ob, st) => const Icon(Icons.token),
                    )
                  : Image.asset(
                      imageUrl.toString(),
                      fit: BoxFit.contain,
                      height: radius,
                      width: radius,
                      errorBuilder: (context, ob, st) =>
                          const Icon(Icons.token),
                    )
              : Jazzicon.getIconWidget(
                  Jazzicon.getJazziconData(160, address: address),
                  size: radius / 1.3),
        );
      },
    );
  }
}
