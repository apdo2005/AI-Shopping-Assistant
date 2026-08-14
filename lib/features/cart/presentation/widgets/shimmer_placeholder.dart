import 'package:flutter/material.dart';

/// A lightweight shimmer effect built with core Flutter APIs only
/// (no external shimmer dependency). Wrap any placeholder box with this
/// to get a subtle "loading" sheen that matches the Cart/Checkout theme.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.baseColor = const Color(0xFFEFEBFA),
    this.highlightColor = const Color(0xFFFAF8FF),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.5 + dx * 3, 0),
              end: Alignment(0.5 + dx * 3, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.baseColor,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}
