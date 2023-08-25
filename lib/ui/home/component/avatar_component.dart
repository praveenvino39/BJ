import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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
            border: Border.all(color: Colors.black, width: 2),
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl ?? "",
                  height: radius,
                  width: radius,
                  errorWidget: (context, ob, st) => const Icon(Icons.token),
                )
              : SvgPicture.network(
                  iconType == null
                      ? "https://avatars.dicebear.com/api/bottts/$address.svg"
                      : "https://avatars.dicebear.com/api/$iconType/$address.svg",
                  height: radius,
                ),
        );
      },
    );
  }
}
