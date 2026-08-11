import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';

class CustomSvgImage extends StatelessWidget {
  const CustomSvgImage({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit,
    this.color,
  });
  final String path;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final svgWidget = SvgPicture.asset(
      path,
      fit: fit ?? BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );

    if (height != null || width != null) {
      return SizedBox(height: height, width: width, child: svgWidget);
    }

    return svgWidget;
  }
}
