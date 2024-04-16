import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LMPostMediaShimmer extends StatelessWidget {
  final LMPostMediaShimmerStyle? style;

  const LMPostMediaShimmer({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    LMPostMediaShimmerStyle shimmerStyle =
        style ?? const LMPostMediaShimmerStyle().basic();
    return Shimmer.fromColors(
      baseColor: shimmerStyle.baseColor ?? Colors.grey.shade300,
      highlightColor: shimmerStyle.highlightColor ?? Colors.grey.shade100,
      child: Container(
        color: Colors.white,
        width: shimmerStyle.width ?? screenSize.width,
        height: shimmerStyle.height ?? screenSize.width,
      ),
    );
  }
}

class LMPostMediaShimmerStyle {
  final double? width;
  final double? height;
  final Color? baseColor;
  final Color? highlightColor;

  const LMPostMediaShimmerStyle({
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
  });

  LMPostMediaShimmerStyle copyWith({
    double? width,
    double? height,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return LMPostMediaShimmerStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      baseColor: baseColor ?? this.baseColor,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  LMPostMediaShimmerStyle basic() {
    return LMPostMediaShimmerStyle(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
    );
  }
}
