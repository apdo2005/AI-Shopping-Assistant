import 'package:flutter/material.dart';
import 'shimmer_placeholder.dart';

/// Renders a product/meal image with a rounded container, a shimmer
/// placeholder while it loads and a graceful fallback icon on error.
/// Reserves a fixed size up-front so the surrounding layout never shifts
/// while the image is loading. Purely presentational — does not touch how
/// the image URL is fetched or where it comes from.
class CartNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderRadius;

  const CartNetworkImage({
    super.key,
    required this.imageUrl,
    this.size = 76,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? _Fallback(radius: radius)
            : Image.network(
                imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ShimmerBox(
                    width: size,
                    height: size,
                    borderRadius: radius,
                  );
                },
                errorBuilder: (_, __, ___) => _Fallback(radius: radius),
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final BorderRadius radius;

  const _Fallback({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FA),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFFB6ADD1),
        size: 22,
      ),
    );
  }
}
