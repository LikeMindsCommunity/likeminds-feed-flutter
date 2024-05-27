import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class SearchScreenShimmer extends StatelessWidget {
  const SearchScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return LMPostMediaShimmer(
      childWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            height: 20,
            width: 100,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
          const SizedBox(height: 20),
          Container(
            height: 30,
            width: screenSize.width * 0.75,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                height: 20,
                width: screenSize.width * 0.15,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0)),
              ),
              SizedBox(width: screenSize.width * 0.1),
              Container(
                height: 20,
                width: screenSize.width * 0.25,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            height: 30,
            width: screenSize.width * 0.75,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                height: 20,
                width: screenSize.width * 0.15,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0)),
              ),
              SizedBox(width: screenSize.width * 0.1),
              Container(
                height: 20,
                width: screenSize.width * 0.25,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            height: 30,
            width: screenSize.width * 0.75,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                height: 20,
                width: screenSize.width * 0.15,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0)),
              ),
              SizedBox(width: screenSize.width * 0.1),
              Container(
                height: 20,
                width: screenSize.width * 0.25,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            height: 20,
            width: 100,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
          const SizedBox(height: 20),
          Container(
            height: 15,
            width: screenSize.width * 0.5,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
          const SizedBox(height: 20),
          Container(
            height: 15,
            width: screenSize.width * 0.5,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
          const SizedBox(height: 20),
          Container(
            height: 15,
            width: screenSize.width * 0.5,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4.0)),
          ),
        ],
      ),
    );
  }
}
