import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

class BannerSlider extends StatelessWidget {
  final List<String> bannerImages;
  final int currentIndex;
  final Function(int) onPageChanged;
  final double height;

  const BannerSlider({
    Key? key,
    required this.bannerImages,
    required this.currentIndex,
    required this.onPageChanged,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: bannerImages.map((image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: height,
                color: Colors.grey[300],
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: double.infinity,
              height: height,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: height,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 10),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        enlargeCenterPage: true,
        viewportFraction: 1,
        enableInfiniteScroll: true,
        onPageChanged: (index, reason) => onPageChanged(index),
      ),
    );
  }
}

class BannerShimmer extends StatelessWidget {
  final double height;

  const BannerShimmer({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
