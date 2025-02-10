import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
          ),
          title: Container(
            width: double.infinity,
            height: 16,
            color: Colors.grey,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 12,
                color: Colors.grey,
              ),
              SizedBox(height: 4),
              Container(
                width: 100,
                height: 12,
                color: Colors.grey,
              ),
            ],
          ),
          trailing: Container(
            width: 80,
            height: 30,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}