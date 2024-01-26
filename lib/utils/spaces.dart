import 'package:flutter/material.dart';

class FillView extends StatelessWidget {
  const FillView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(child: SizedBox());
  }
}

enum SpacingSize { xs, s, m, l, xl, xxl, xxxl }

Widget addHeight(SpacingSize size) {
  var spacing = 0.0;
  switch (size) {
    case SpacingSize.xs:
      spacing = 10;
      break;
    case SpacingSize.s:
      spacing = 20;
      break;
    case SpacingSize.m:
      spacing = 30;
      break;
    case SpacingSize.l:
      spacing = 40;
      break;
    case SpacingSize.xl:
      spacing = 50;
      break;
    case SpacingSize.xxl:
      spacing = 60;
      break;
    case SpacingSize.xxxl:
      spacing = 70;
      break;
  }
  return SizedBox(height: spacing);
}
