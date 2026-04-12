import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/game_models.dart';

class ItemImage extends StatelessWidget {
  final GameItem? item;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? iconColor;

  const ItemImage({
    super.key,
    this.item,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.iconColor = Colors.purpleAccent,
  });

  @override
  Widget build(BuildContext context) {
    final String? effectiveUrl = imageUrl ?? item?.imageUrl;

    if (effectiveUrl == null || effectiveUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (effectiveUrl.startsWith('assets/')) {
      return Image.asset(
        effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return CachedNetworkImage(
      imageUrl: effectiveUrl,
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: iconColor?.withOpacity(0.5) ?? Colors.white24,
        size: (width != null) ? width! * 0.4 : 24,
      ),
    );
  }
}
